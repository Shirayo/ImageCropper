//
//  SettingsView.swift
//  ImageCropper
//
//  Created by Shirayo on 11/09/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel: SettingsViewModel
    @State private var isAboutOpened: Bool = false
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    isAboutOpened = true
                }, label: {
                    Text("Button")
                        .foregroundStyle(Color.mainText)
                })
            }
            .background(Color.mainColor)
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $isAboutOpened, content: {
                Text("Made By Vasili Shirayo Mordus")
                    .foregroundStyle(Color.mainText)
                    .presentationDetents([.height(100)])
            })
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
