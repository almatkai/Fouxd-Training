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
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @StateObject private var languageService = LocalizationService.shared
    @State private var selectedLanguage: Language
    @State private var scrollOffset: CGFloat = 0
    
    init() {
        _selectedLanguage = State(initialValue: LocalizationService.shared.language)
    }
    @State var logOut = false
    var body: some View {
        NavigationStack {
            ScrollView {
//                GeometryReader { geometry in
                    ZStack {
//                        let scrollOffset = geometry.frame(in: .local).minY
//                        Image("background_circles")
//                            .frame(width: width())
//                            .offset(y: -height() * 0.3 + scrollOffset * 0.4)
//                            .opacity(0.4)
                        VStack(spacing: 20) {
                            ZStack {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            logOut = true
                                        }){
                                            Image(systemName: "door.left.hand.open")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 18)
                                        }
                                        .padding(24)
                                    }
                                    Spacer()
                                }
                                if let googleUser = userSessionVM.userSession {
                                    // Google User Profile
                                    googleUserProfile(user: googleUser)
                                } else {
                                    // Local User Profile
                                    localUserProfile
                                }
                            }
                            
                            // Action Buttons
                            HStack(spacing: 20) {
                                NavigationLink(destination: EditPlanView()) {
                                    Label("Plan", systemImage: "calendar")
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background {
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(.cGradientBlue1), Color(.cGradientBlue2)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        }
                                        .cornerRadius(20)
                                }
                                
                                Button(action: {
                                    showSettings.toggle()
                                    vibrate()
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(.cGradientPurple1), Color(.cGradientPurple2)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .opacity(0.8)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                LanguageChangerView()
                                ThemingChangerView()
                                AboutUsView()
                                PrivacyPolicyView()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(22)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            
                            VStack {}.padding()
                        }
                    }
//                }
            }
            .confirmationDialog(
                "Log out?",
                isPresented: $logOut
            ) {
                Button("Log Out", role: .destructive) {
                    authViewModel.logOut()
                    userSessionVM.refreshUser()
                    userDataVM.userData = UserData()
                    planVM.plans = []
                    isFirstLaunch = true
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
        .tint(Color("cTintColor"))
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
}


struct StatsView: View {
    let weight: String
    let height: String
    let activityLevel: String
    
    var body: some View {
        HStack(spacing: 40) {
            StatItem(value: LocalizedStringResource(stringLiteral: weight), title: LocalizedStringResource(stringLiteral: "Weight"))
            StatItem(value: LocalizedStringResource(stringLiteral: height), title: LocalizedStringResource(stringLiteral: "Height"))
            StatItem(value: LocalizedStringResource(stringLiteral: activityLevel), title: LocalizedStringResource(stringLiteral: "Activity Level"))
        }
    }
}

struct StatItem: View {
    let value: LocalizedStringResource
    let title: LocalizedStringResource
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
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

struct Row: View {
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
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

