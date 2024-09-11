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
    var unactiveTint: Color
    var tab: Tab
    var animation: Namespace.ID
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: tab.systemImage)
                .font(.title2)
                .foregroundStyle(tab == selectedTab ? tint : unactiveTint)
                .frame(width:  tab == selectedTab ? 54 : 34, height:  tab == selectedTab ? 54 : 36)
                .background {
                    if tab == selectedTab {
                        Circle().fill(Color("MainColor"))
                            .shadow(radius: 5)
                    }
                }
                                            
            Text(tab.rawValue)
                .font(.system(size: 10))
                .foregroundStyle(tab == selectedTab ? tint : unactiveTint)
                .clipped()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = tab
        }
    }
}
