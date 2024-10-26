//
//  NavigationButton.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 20.10.2024.
//

import SwiftUI

struct NavigationButton: View {
    
    private let action: () -> Void
    private let imageName: String
    private let width: CGFloat
    
    init(action: @escaping () -> Void, imageName: String, width: CGFloat) {
        self.action = action
        self.imageName = imageName
        self.width = width
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
            vibrate()
        }) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundStyle(Color(hex: "#AB8DA8"))
                .padding()
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(hex: "#AB8DA8"), lineWidth: 2)
                )
        }
        .frame(maxWidth: width)
    }
}
