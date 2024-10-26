//
//  GoogleSingInButton.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 18.10.2024.
//

import SwiftUI

struct GoogleSingInButton: View {
    
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var action: () -> Void
    
    var body: some View {
        Button(action:
            action
        ) {
            HStack {
                HStack {
                    if let userSession = userSessionVM.userSession {
                        if let url = userSession.photoURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image("fallbackImageName")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                        }
                        
                        VStack {
                            Text(userSession.displayName ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.footnote)
                            Text(userSession.email ?? "")
                                .font(.caption2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                            
                        }
                        
                        Text("Tap to log out")
                    } else {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                        Text("Sign in with Google")
                    }
                }
                .padding()
            }
            .classicButton(screenWidth: width() * 0.8)
        }
    }
}

struct CustomStyle: ViewModifier {
    var screenWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.blue)
            .cornerRadius(30)
            .frame(maxWidth: screenWidth)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

extension View {
    func classicButton(screenWidth: CGFloat) -> some View {
        self.modifier(CustomStyle(screenWidth: screenWidth))
    }
}
