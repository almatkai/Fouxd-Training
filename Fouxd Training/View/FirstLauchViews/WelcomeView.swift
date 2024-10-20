//
//  WelcomeView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 20.10.2024.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject private var globalVM: GlobalVM
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Binding var pageCounter: Int
    
    var body: some View {
        ZStack {
            VStack {
                Image("intro")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            VStack {
                Spacer()
                Spacer()
                VStack(alignment: .leading) {
                    Text("Let's start training!")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.cpurple))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(.bold)
                        .padding(.vertical)
                    
                    Text("Log in to your personal account to save your progress")
                        .font(.title3)
                        .foregroundStyle(Color(.cpurple))
                }.padding(32)
                Spacer()
            }
            VStack {
                Spacer()
                GoogleSingInButton(action: {
                    Task {
                        if globalVM.userSession == nil {
                            await authViewModel.signInWithGoogle { _ in
                                pageCounter += 1
                            }
                        } else {
                            authViewModel.logOut()
                        }
                        globalVM.refreshUser()
                    }
                })
                
                Button(action: {
                    withAnimation{
                        pageCounter += 1
                    }
                }) {
                    HStack {
                        HStack {
                            Text("Continue")
                                .foregroundStyle(Color(hex: "#AB8DA8"))
                            Image(systemName: "chevron.right.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundStyle(Color(hex: "#AB8DA8"))
                        }
                        .padding()
                    }
                    .foregroundColor(.blue)
                    .cornerRadius(30)
                    .frame(maxWidth: globalVM.screenWidth * 0.8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color(hex: "#AB8DA8"), lineWidth: 2)
                    )
                }
                .padding(.bottom, 42)
            }
        }
    }
}
