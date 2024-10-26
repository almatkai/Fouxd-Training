//
//  WelcomeView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 20.10.2024.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @EnvironmentObject private var userDataVM: UserDataViewModel
    @EnvironmentObject private var planVM: PlanViewModel
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Binding var pageCounter: Int
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
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
                        await handleSignIn()
                    }
                    userSessionVM.refreshUser()
                })
                .padding(.bottom, userSessionVM.userSession != nil ? 0 : 42)
                if userSessionVM.userSession != nil {
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
                        .frame(maxWidth: width()     * 0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(hex: "#AB8DA8"), lineWidth: 2)
                        )
                    }.padding(.bottom, 42)
                }
            }
        }
    }
    
    private func handleSignIn() async {
        print("Starting handleSignIn")  // Initial debug point
        
        if userSessionVM.userSession == nil {
            print("User session is nil, proceeding with sign in")  // Check if we enter this block
            
            await authViewModel.signInWithGoogle { result in
                print("Google sign in callback received")  // Check if callback is triggered
                
                Task {
                    do {  // Add do-catch for better error handling
                        switch result {
                        case .success(let status):
                            print("Sign in successful, status: \(status)")
                            
                            userSessionVM.refreshUser()
                            guard let userId = userSessionVM.userSession?.uid else {
                                print("Failed to get userId from userSession")
                                return
                            }
                            
                            print("Got userId: \(userId)")
                            let isUserExist = await userDataVM.isUserDataExist(userId: userId)
                            print("User exists: \(isUserExist)")
                            
                            if isUserExist {
                                let isPlanExist = await planVM.isPlanExist(
                                    userData: userDataVM.userData,
                                    userId: userId
                                )
                                print("Plan exists: \(isPlanExist)")
                                
                                if isPlanExist {
                                    await MainActor.run {
                                        print("Updating UI for existing plan")
                                        withAnimation {
                                            isFirstLaunch = false
                                            pageCounter += 1
                                        }
                                    }
                                } else {
                                    await MainActor.run {
                                        print("Updating UI for non plan")
                                        withAnimation {
                                            pageCounter += 2
                                        }
                                    }
                                }
                            } else {
                                await MainActor.run {
                                    print("Updating UI for non plan")
                                    withAnimation {
                                        pageCounter += 1
                                    }
                                }
                            }
                            
//                            await MainActor.run {
//                                print("Final UI update")
//                                withAnimation {
//                                    isFirstLaunch = false
//                                    pageCounter += 1
//                                }
//                            }
                            
                        case .failure(let error):
                            print("Google sign-in failed with error: \(error)")
                            print("Error description: \(error.localizedDescription)")
                        }
                    } catch {
                        print("Unexpected error in Task: \(error)")
                    }
                }
            }
        } else {
            print("User already signed in, logging out")
            authViewModel.logOut()
            userSessionVM.refreshUser()
        }
        
    }
}
