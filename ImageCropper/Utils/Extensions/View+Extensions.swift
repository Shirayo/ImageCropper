//
//  View+Extensions.swift
//  ImageCropper
//
//  Created by Shirayo on 13/09/2024.
//

import Foundation
import SwiftUI

extension View {
    func centerVertically() -> some View {
        modifier(CenterVertically())
    }
    
    func centerHorizontally() -> some View {
        modifier(CenterVertically())
    }
}


struct CenterVertically: ViewModifier {
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            content
            
            Spacer()
        }
    }
}

struct CenterHorizontally: ViewModifier {
    
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            
            content
            
            Spacer()
        }
    }
}


