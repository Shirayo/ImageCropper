//
//  CropView.swift
//  ImageCropper
//
//  Created by Shirayo on 11/09/2024.
//

import SwiftUI
import PhotosUI

struct CropView: View {
    
    @StateObject var viewModel: CropViewModel
    
    init(viewModel: CropViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        UINavigationBar.appearance().isTranslucent = false
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                Color.main
                
                if viewModel.isImageChosen {
                        CropImageView(
                            image: $viewModel.selectedImage,
                            totalOffset: $viewModel.totalOffset,
                            currentOffset: $viewModel.currentOffset,
                            currentZoom: $viewModel.currentZoom,
                            totalZoom: $viewModel.totalZoom,
                            wholeImageOpacity: $viewModel.wholeImageOpacity,
                            isFilterOn: $viewModel.isFilterOn,
                            frameRotation: $viewModel.frameRotation
                        )
                    VStack {
                        HStack {
                            Spacer()
                            
                            Toggle(
                                "B/W",
                                systemImage: viewModel.isFilterOn ? "paintbrush.fill" : "paintbrush",
                                isOn: $viewModel.isFilterOn
                            )
                            .font(.title2)
                            .foregroundStyle(Color("MainTextColor"))
                            .tint(Color("MainTextColor"))
                            .toggleStyle(.button)
                            .contentTransition(.symbolEffect)
                        }
                        
                        Spacer()
                    }
                } else {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .foregroundStyle(Color("MainTextColor"))
                        
                        
                        HStack(spacing: 4) {
                            Spacer()

                            Text("Choose")
                                .foregroundStyle(Color("MainTextColor"))
                            
                            PhotosPicker(
                                selection: $viewModel.photoSelection,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Text("photo")
                            }
                            
                            Text("to crop")
                                .foregroundStyle(Color("MainTextColor"))
                            
                            Spacer()
                        }
                        
                        Spacer()

                    }
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isImageChosen {
                        PhotosPicker(
                            selection: $viewModel.photoSelection,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("new")
                                .foregroundStyle(Color("MainTextColor"))
                        }
                    } else {
                        Spacer()
                    }
                }
            }
            .toolbar(content: {
                if viewModel.isImageChosen {
                    Button(action: {
                        viewModel.savePhoto()
                    }, label: {
                        Text("Save")
                            .foregroundStyle(Color("MainTextColor"))
                    })
                } else {
                    Spacer()
                }
            })
            .onChange(of: viewModel.photoSelection) { oldValue, newValue in
                Task {
                    await viewModel.setPhoto(newValue: newValue)
                }
            }
            
        }
        .edgesIgnoringSafeArea(.top)
        .alert("Please enable permission to save photos in your app settings", isPresented: $viewModel.isPermissionDenied) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct CropImageView: View {
    @Binding var image: UIImage?
    @Binding var totalOffset: CGSize
    @Binding var currentOffset: CGSize
    @Binding var currentZoom: Double
    @Binding var totalZoom: Double
    @Binding var wholeImageOpacity: Double
    @Binding var isFilterOn: Bool
    @Binding var frameRotation: Angle
    @State private var isGestureActive = false
    private let frameWidth: CGFloat = 150
    private let frameHeight: CGFloat = 300
    private let outerImageOpacity = 0.5
    private let frameLineWidth = 2.0
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(currentZoom + totalZoom)
                    .opacity(wholeImageOpacity)
                    .grayscale(isFilterOn ? 1 : 0)
                    .rotationEffect(frameRotation)
                    .frame(width: frameWidth, height: frameHeight)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(currentZoom + totalZoom)
                    .grayscale(isFilterOn ? 1 : 0)
                    .rotationEffect(frameRotation)
                    .frame(width: frameWidth, height: frameHeight)
                    .mask({
                        Rectangle()
                            .frame(width: frameWidth, height: frameHeight)
                            .offset(x: currentOffset.width + totalOffset.width)
                            .offset(y: currentOffset.height + totalOffset.height)
                    })
                    .background {
                        Rectangle()
                            .stroke(lineWidth: frameLineWidth)
                            .frame(width: frameWidth, height: frameHeight)
                            .offset(x: currentOffset.width + totalOffset.width)
                            .offset(y: currentOffset.height + totalOffset.height)
                        
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if !isGestureActive {
                                    withAnimation {
                                        wholeImageOpacity = outerImageOpacity
                                    }
                                    isGestureActive = true
                                }
                                
                                currentOffset = gesture.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    wholeImageOpacity = 0
                                }
                                isGestureActive = false
                                totalOffset.width += currentOffset.width
                                totalOffset.height += currentOffset.height
                                currentOffset = .zero
                            }
                    )
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                withAnimation {
                                    wholeImageOpacity = outerImageOpacity
                                }
                                currentZoom = value.magnification - 1
                            }
                            .simultaneously(
                                with: RotationGesture()
                                    .onChanged { gesture in
                                        frameRotation = gesture
                                        print(frameRotation.degrees)
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            wholeImageOpacity = 0
                                        }
                                    }
                                
                            )
                            .onEnded { value in
                                withAnimation {
                                    wholeImageOpacity = 0
                                }
                                totalZoom += currentZoom
                                currentZoom = 0
                            }
                    )
            }
        }
    }
}


#Preview {
    CropView(viewModel: CropViewModel())
}
