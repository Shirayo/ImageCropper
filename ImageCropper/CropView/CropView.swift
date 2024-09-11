//
//  CropView.swift
//  ImageCropper
//
//  Created by Apple on 11/09/2024.
//

import SwiftUI
import PhotosUI

struct CropView: View {
    
    @State var isFilterOn: Bool = false
    @State var isImageChosen: Bool = false
    @State var selectedImage: UIImage?
    @State var photoSelection: PhotosPickerItem? = nil
    @State var currentOffset: CGSize = .zero
    @State var totalOffset: CGSize = .zero
    @State var currentZoom: Double = 0.0
    @State var totalZoom: Double = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainColor")

                VStack(alignment: .center) {
                    if isImageChosen {
                        HStack {
                            Spacer()
                            
                            Toggle(
                                "B/W",
                                systemImage: isFilterOn ? "paintbrush.fill" : "paintbrush",
                                isOn: $isFilterOn
                            )
                            .font(.title2)
                            .toggleStyle(.button)
                            .contentTransition(.symbolEffect)
                        }
                        
                        if let selectedImage = selectedImage {
                            CropImageView(
                                image: Image(uiImage: selectedImage),
                                totalOffset: $totalOffset,
                                currentOffset: $currentOffset,
                                currentZoom: $currentZoom,
                                totalZoom: $totalZoom
                            )
                        }
                    } else {
                        Spacer()
                        
                        VStack {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .foregroundStyle(Color("MainTextColor"))
                            
                            
                            HStack(spacing: 4) {
                                Text("Choose")
                                    .foregroundStyle(Color("MainTextColor"))
                                
                                PhotosPicker(
                                    selection: $photoSelection,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    Text("photo")
                                }
                                
                                Text("to crop")
                                    .foregroundStyle(Color("MainTextColor"))
                            }
                            
                        }
                        
                        Spacer()
                    }
                }
                .toolbar(content: {
                    if isImageChosen {
                        Button(action: {
                            guard let selectedImage = selectedImage else {
                                return
                            }
                            let croppedImage = ZStack {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 135, height: 240)
                                    .scaleEffect(currentZoom + totalZoom)
                                    .offset(x: -currentOffset.width - totalOffset.width)
                                    .offset(y: -currentOffset.height - totalOffset.height)
                            }
                            .clipped()
                            
                            let ren = ImageRenderer(
                                content: croppedImage
                            )
                            ren.scale = UIScreen.main.scale
                            if let image = ren.uiImage{
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            } else {
                                print("ERROR SAVING PHOTO")
                            }
                        }, label: {
                            Text("Save")
                        })
                    } else {
                        Spacer()
                    }
                    
                })
            }
            .onChange(of: photoSelection) { oldValue, newValue in
                Task {
                    if let photoSelection = newValue,
                       let data = try? await photoSelection.loadTransferable(type: Data.self)
                    {
                        if let image = UIImage(data: data) {
                            selectedImage = image
                            isImageChosen = true
                        } else {
                            print("ERROR")
                        }
                    }
                }
            }
        }
    }
}

struct CropImageView: View {
    @State var image: Image
    @Binding var totalOffset: CGSize
    @Binding var currentOffset: CGSize
    @State private var size = CGSize.zero
    @Binding var currentZoom: Double
    @Binding var totalZoom: Double
    @State private var frameRotation: Angle = .zero
    @State private var imageSize: CGSize = .zero
    @State private var wholeImageOpacity = 0.0
    @State private var isGestureActive = false
    var body: some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .scaleEffect(currentZoom + totalZoom)
                .opacity(wholeImageOpacity)
                .frame(width: 135, height: 240)
            image
                .resizable()
                .scaledToFill()
                .scaleEffect(currentZoom + totalZoom)
                .frame(width: 135, height: 240)
                .mask({
                    Rectangle()
                        .frame(width: 135, height: 240)
                        
                        .rotationEffect(frameRotation)
                        .offset(x: currentOffset.width + totalOffset.width)
                        .offset(y: currentOffset.height + totalOffset.height)
                })
                .background {
                    Rectangle()
                        .stroke(lineWidth: 2)
                        .frame(width: 135, height: 240)
                        .rotationEffect(frameRotation)
                        .offset(x: currentOffset.width + totalOffset.width)
                        .offset(y: currentOffset.height + totalOffset.height)
                    
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if !isGestureActive {
                                withAnimation {
                                    wholeImageOpacity = 0.5
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
                                wholeImageOpacity = 0.5
                            }
                            currentZoom = value.magnification - 1
                        }
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


#Preview {
    CropView()
}
