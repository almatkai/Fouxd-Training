//
//  ProfileView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 17.10.2024.
//

import SwiftUI
import FirebaseAuth


struct ProfileView: View {
    @EnvironmentObject var userSessionVM: UserSessionViewModel
    @EnvironmentObject var userDataVM: UserDataViewModel
    @EnvironmentObject var planVM: PlanViewModel
    
    @State private var showSettings = false
    @StateObject private var authViewModel = AuthenticationViewModel()
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let googleUser = userSessionVM.userSession {
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
                        
                        Button(action: {
                            showSettings.toggle()
                            vibrate()
                        }) {
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
                    
                    if (userSessionVM.userSession == nil) {
                        GoogleSingInButton(action: {
                            Task {
                                await signInAction()
                            }
                        })
                    } else {
                        Button(action: {
                            authViewModel.logOut()
                            userSessionVM.refreshUser()
                            userDataVM.userData = UserData()
                            planVM.plans = []
                            isFirstLaunch = true
                        }){
                            HStack {
                                HStack {
                                    Text("Log out")
                                }
                                .padding()
                            }
                            .classicButton(screenWidth: width())
                            .padding(32)
                        }
                    }
                    VStack {}.padding()
                }
            }
        }
    }
    
    private func enterAccount() async {
        await userDataVM.checkAndCreateData(userId: userSessionVM.userSession?.uid ?? "")
        await planVM.checkAndCreatePlans(userData: userDataVM.userData, userId: userSessionVM.userSession?.uid ?? "")
        userSessionVM.refreshUser()
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
                weight: String(userDataVM.userData.weight),
                height: String(userDataVM.userData.height),
                activityLevel: userDataVM.userData.activityLevel.rawValue)
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
                weight: "\(userDataVM.userData.weight)",
                height: "\(userDataVM.userData.height)",
                activityLevel: "\(userDataVM.userData.activityLevel)"
            )
        }
        .padding(.top, 20)
    }
    
    private func signInAction() async {
        if userSessionVM.userSession == nil {
            await authViewModel.signInWithGoogle(completion: {_ in})
            userSessionVM.refreshUser()

            guard let userSession = userSessionVM.userSession else { return }

            let result = await withCheckedContinuation { continuation in
                FBMUserData.shared.fetchUserData(uid: userSession.uid) { res in
                    continuation.resume(returning: res)
                }
            }

            switch result {
            case .success(let userData):
                userDataVM.userData = userData
            case .failure(_):
                await createAccount()
            }
        } else {
            authViewModel.logOut()
        }
        userSessionVM.refreshUser()
    }

    private func createAccount() async {
        userDataVM.createUserData(userSession: userSessionVM.userSession)
        planVM.createPlans(userData: userDataVM.userData)
        HealthKitService.shared.setup()
        await Task {
            await planVM.savePlans(userSession: userSessionVM.userSession)
        }.value
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

struct EditButton: View {
    @Binding var isEditing: Bool
    var body: some View {
        Button(action: {
            withAnimation{
                isEditing.toggle()
            }
            vibrate()
        }){
            Image(systemName: "square.and.pencil")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(.blue)
        }
        .padding(.bottom, 10)
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

