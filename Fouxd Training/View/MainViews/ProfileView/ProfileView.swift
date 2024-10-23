//
//  ProfileView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 17.10.2024.
//

import SwiftUI
import FirebaseAuth


struct ProfileView: View {
    @EnvironmentObject private var globalVM: GlobalVM
    
    @State private var showSettings = false
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let googleUser = globalVM.userSession {
                        // Google User Profile
                        googleUserProfile(user: googleUser)
                    } else {
                        // Local User Profile
                        localUserProfile
                    }
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        NavigationLink(destination: EditPlanView()) {
                            Label("Plan", systemImage: "calendar")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showSettings.toggle() }) {
                            Label("Settings", systemImage: "gear")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Content Sections
                    VStack(spacing: 15) {
                        SectionCard(title: "Recent Activity", icon: "clock.fill") {
                            VStack(alignment: .leading, spacing: 12) {
                                ActivityRow(icon: "heart.fill", text: "Liked 'Post Title'", time: "2h ago")
                                ActivityRow(icon: "bookmark.fill", text: "Saved 'Another Post'", time: "5h ago")
                                ActivityRow(icon: "message.fill", text: "Commented on 'Post'", time: "1d ago")
                            }
                        }
                        
                        SectionCard(title: "Saved Items", icon: "bookmark.fill") {
                            VStack(alignment: .leading, spacing: 12) {
                                SavedItemRow(title: "Saved Post 1", date: "Yesterday")
                                SavedItemRow(title: "Saved Post 2", date: "2 days ago")
                                SavedItemRow(title: "Saved Post 3", date: "1 week ago")
                            }
                        }
                    }.padding(.horizontal)
                    
                    if (globalVM.userSession == nil) {
                        GoogleSingInButton(action: {
                            Task {
                                await singInAction()
                            }
                        })
                    } else {
                        Button(action: {
                            authViewModel.logOut()
                            globalVM.refreshUser()
                        }){
                            HStack {
                                HStack {
                                    Text("Log out")
                                }
                                .padding()
                            }
                            .classicButton(screenWidth: globalVM.screenWidth)
                            .padding(32)
                        }
                    }
                    VStack {}.padding()
                }
            }
        }
    }
    
    // Google User Profile View
    private func googleUserProfile(user: User) -> some View {
        VStack {
            AsyncImage(url: URL(string: user.photoURL?.absoluteString ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            .shadow(radius: 5)
            
            Text(user.displayName ?? "User")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            Text(user.email ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            StatsView(
                weight: String(globalVM.userData.weight),
                height: String(globalVM.userData.height),
                activityLevel: globalVM.userData.activityLevel.rawValue)
        }
        .padding(.top, 20)
    }
    
    private var localUserProfile: some View {
        VStack(spacing: 25) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .background(Circle().fill(Color(.systemBackground)))
                .shadow(radius: 5)
            
            StatsView(
                weight: "\(globalVM.userData.weight)",
                height: "\(globalVM.userData.height)",
                activityLevel: "\(globalVM.userData.activityLevel)"
            )
        }
        .padding(.top, 20)
    }
    
    private func  singInAction() async {
        if globalVM.userSession == nil {
            await authViewModel.signInWithGoogle { _ in
                globalVM.refreshUser()
                guard let userSession = globalVM.userSession else { return }
                FBMUserData.shared.fetchUserData(uid: userSession.uid, completion: { res in
                    switch res {
                    case .success(let userData):
                        globalVM.userData = userData
                    case .failure(_):
                        FBMUserData.shared.createUserData(uid: userSession.uid, data: globalVM.userData)
                    }
                })
            }
        } else {
            authViewModel.logOut()
        }
        globalVM.refreshUser()
    }
}

struct StatsView: View {
    let weight: String
    let height: String
    let activityLevel: String
    
    var body: some View {
        HStack(spacing: 40) {
            StatItem(value: weight, title: "Weight")
            StatItem(value: height, title: "Height")
            StatItem(value: activityLevel, title: "Activity Level")
        }
        .padding(.vertical)
    }
}

struct StatItem: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let text: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct SavedItemRow: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

