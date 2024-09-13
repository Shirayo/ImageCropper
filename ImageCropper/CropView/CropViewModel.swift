//
//  CropViewModel.swift
//  ImageCropper
//
//  Created by Shirayo on 11/09/2024.
//

import Foundation
import SwiftUI
import PhotosUI

class CropViewModel: ObservableObject {
    
    @Published var isFilterOn: Bool = false
    @Published var isImageChosen: Bool = false
    @Published var isPermissionDenied: Bool = false
    @Published var selectedImage: UIImage?
    @Published var photoSelection: PhotosPickerItem? = nil
    @Published var currentOffset: CGSize = .zero
    @Published var totalOffset: CGSize = .zero
    @Published var currentZoom: Double = 0.0
    @Published var totalZoom: Double = 1
    @Published var wholeImageOpacity: Double = 0
    @Published var frameRotation: Angle = .degrees(0)
    
    @MainActor
    func setPhoto(newValue: PhotosPickerItem?) async {
        if let photoSelection = newValue,
           let data = try? await photoSelection.loadTransferable(type: Data.self)
        {
            if let image = UIImage(data: data) {
                selectedImage = image
                setDefaultSettings()
            } else {
                print("ERROR")
            }
        }
    }
    
    @MainActor
    func savePhoto() {
        guard let selectedImage = selectedImage else {
            return
        }
        let croppedImage = ZStack {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 300)
                .rotationEffect(frameRotation)
                .scaleEffect(currentZoom + totalZoom)
                .grayscale(isFilterOn ? 1 : 0)
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
            isPermissionDenied = PHPhotoLibrary.authorizationStatus(for: .addOnly).rawValue == 2 ? true : false
        } else {
            print("ERROR SAVING PHOTO")
        }
    }
    private func setDefaultSettings() {
        isImageChosen = true
        currentZoom = 0
        totalZoom = 1
        currentOffset = .zero
        totalOffset = .zero
        frameRotation = .degrees(0)
    }
}
