//
//  ContentView.swift
//  ImageCropper
//
//  Created by Shirayo on 11/09/2024.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTab: Tab = .crop
    @Namespace private var animation
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                CropView()
                    .tag(Tab.crop)
                
                SettingsView()
                    .tag(Tab.settings)
            }
            
            CustomTabBar(
                tint: Color("MainTextColor"),
                unactiveTint: Color("MainTextColor")
            )
            
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func CustomTabBar(tint: Color, unactiveTint: Color) -> some View {
        HStack(alignment: .bottom) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabItem(
                    tint: tint,
                    unactiveTint: unactiveTint,
                    tab: tab,
                    animation: animation,
                    selectedTab: $selectedTab
                )
            }
        }
        .padding(.bottom, 24)
        .padding(.top, 8)
        .padding(.horizontal)
        .background {
            Rectangle()
                .fill(Color("MainColor"))
                .background {
                    Rectangle()
                        .offset(y: -10)
                        .fill(Color("MainColor"))
                        .brightness(0.05)
                        .blur(radius: 10)
                }
        }
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.5), value: selectedTab)
        
    }
}


#Preview {
    MainView()
}
