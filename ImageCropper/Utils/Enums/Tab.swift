//
//  Tab.swift
//  ImageCropper
//
//  Created by Apple on 11/09/2024.
//

import Foundation

enum Tab: String, CaseIterable {
    case crop = "Crop"
    case settings = "Settings"
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
    
    var systemImage: String {
        switch self {
        case .crop:
            return "crop"
        case .settings:
            return "gearshape"
        }
    }
}
