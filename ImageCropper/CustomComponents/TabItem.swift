//
//  TabItem.swift
//  ImageCropper
//
//  Created by Shirayo on 11/09/2024.
//

import Foundation
import SwiftUI

struct TabItem: View {
    
    var tint: Color
    var tab: Tab
    var animation: Namespace.ID
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: tab.systemImage)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width:  tab == selectedTab ? 54 : 34, height:  tab == selectedTab ? 54 : 36)
                .background {
                    if tab == selectedTab {
                        Circle()
                            .fill(Color("MainColor"))
                            .offset(x: 2, y: 2)
                            .brightness(0.1)
                            .blur(radius: 3.0)
                            .overlay {
                                Circle()
                                    .fill(Color("MainColor"))
                            }
                            .background {
                                Circle()
                                    .fill(Color("MainColor"))
                                    .offset(x: -2, y: -2)
                                    .blur(radius: 3.0)
                                    .brightness(-0.1)
                            }
                    }
                }
                                            
            Text(tab.rawValue)
                .font(.system(size: 10))
                .foregroundStyle(tint)
                .clipped()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = tab
        }
    }
}

#Preview {

    ZStack {
        @Namespace var animation
        @State var selector: Tab = .settings
        Color("MainColor")
        VStack {
            TabItem(tint: .red, tab: .crop, animation: animation, selectedTab: .constant(.crop))

            Button("press me") {
                selector = .crop
            }
        }
    }
}
