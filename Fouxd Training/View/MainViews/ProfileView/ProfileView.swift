//
//  ProfileView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 17.10.2024.
//

import SwiftUI
import FirebaseAuth


struct ProfileView: View {
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @EnvironmentObject private var userDataVM: UserDataViewModel
    @EnvironmentObject private var planVM: PlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @StateObject private var languageService = LocalizationService.shared
    @State private var selectedLanguage: Language
    @State var editMode = false
    @State var pickerType: PickerType = .weight
    init() {
        _selectedLanguage = State(initialValue: LocalizationService.shared.language)
    }
    @State var logOut = false
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
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
                                googleUserProfile(user: googleUser)
                            } else {
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
                                withAnimation(.easeInOut(duration: 0.3)){
                                    editMode.toggle()
                                }
                                if editMode {
                                    userDataVM.updateUserData(userSession: userSessionVM.userSession)
                                }
                            }) {
                                Label(editMode ? "Save" : "Edit", systemImage: "pencil")
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
                        
                        
                        if editMode {
                            userMetricsEdit
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .move(edge: .bottom).combined(with: .opacity)
                                    )
                                )
                        }
                        
                        settings
                        
                        VStack {}.padding()
                    }
                }
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
                activityLevel: userDataVM.userData.activityLevel.rawValue,
                editMode: $editMode)
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
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
                activityLevel: "\(userDataVM.userData.activityLevel)",
                editMode: $editMode
            )
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var settings: some View {
        VStack(alignment: .leading, spacing: 12) {
            LanguageChangerView()
            Divider()
            ThemingChangerView()
            Divider()
            AboutUsView()
            Divider()
            PrivacyPolicyView()
        }
        .padding()
        .background(Color(.cwhiteAndDarkGray))
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var userMetricsEdit: some View {
        HStack {
            VStack {
                ForEach(PickerType.allCases, id: \.self) { type in
                    buttonWithBackground(for: type)
                }
                Spacer()
            }
            .padding()
            .background(Color(.cwhiteAndDarkGray))
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .frame(width: width() * 0.6)
            
            VStack {
                pickerView()
            }
            
        }
    }
    
    @Namespace private var animation
    private func buttonWithBackground(for type: PickerType) -> some View {
        ZStack(alignment: .leading) {
            if pickerType == type {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.2))
                    .matchedGeometryEffect(id: "background", in: animation)
            }
            button(for: type)
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
        }
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut, value: pickerType)
    }
    
    private func button(for type: PickerType, text: String? = nil) -> some View {
        Button(action: {
            withAnimation {
                pickerType = type
            }
        }) {
            Text(buttonText(for: type))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
                .fontWeight(pickerType == type ? .heavy : .medium)
        }
        .foregroundColor(pickerType == type ? .blue : .secondary)
    }
    
    private func buttonText(for type: PickerType) -> LocalizedStringResource {
        switch type {
        case .weight:
            return LocalizedStringResource(stringLiteral: String(format: "Weight: %.1f kg", userDataVM.userData.weight))
        case .height:
            return "Height: \(Int(userDataVM.userData.height)) cm"
        case .age:
            return "Age: \(userDataVM.userData.age) years"
        case .gender:
            return "Gender: \(userDataVM.userData.gender == .male ? "Male" : userDataVM.userData.gender == .female ? "Female" : "Other")"
        case .activityLevel:
            return "Effort: \(userDataVM.userData.activityLevel.rawValue)"
        }
    }
    
    private func pickerView() -> some View {
        Group {
            switch pickerType {
            case .weight:
                Picker("Weight", selection: $userDataVM.userData.weight) {
                    ForEach(Array(stride(from: 10, to: 300, by: 0.5)), id: \.self) { weight in
                        Text("\(String(format: weight.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", weight)) kg")
                            .tag(Double(weight))
                            .font(.callout)
                    }
                }
            case .height:
                Picker("Height", selection: $userDataVM.userData.height) {
                    ForEach(100...250, id: \.self) { height in
                        Text("\(height) cm").tag(Double(height)).font(.callout)
                    }
                }
            case .age:
                Picker("Age", selection: $userDataVM.userData.age) {
                    ForEach(1...100, id: \.self) { age in
                        Text("\(age) years").tag(age).font(.callout)
                    }
                }
            case .gender:
                Picker("Gender", selection: $userDataVM.userData.gender) {
                    Text("Male").tag(Gender.male).font(.callout)
                    Text("Female").tag(Gender.female).font(.callout)
                    Text("Other").tag(Gender.other).font(.callout)
                }
            case .activityLevel:
                Picker("Activity Level", selection: $userDataVM.userData.activityLevel) {
                    Text("Sedentary").tag(ActivityLevel.sedentary).font(.callout)
                    Text("Light").tag(ActivityLevel.light).font(.callout)
                    Text("Moderate").tag(ActivityLevel.moderate).font(.callout)
                    Text("Active").tag(ActivityLevel.active).font(.callout)
                }
            }
        }
        .pickerStyle(WheelPickerStyle())
        .padding()
    }
}


struct StatsView: View {
    let weight: String
    let height: String
    let activityLevel: String
    @Binding var editMode: Bool
    
    var body: some View {
        if !editMode {
            HStack(spacing: 40) {
                StatItem(value: LocalizedStringResource(stringLiteral: weight), title: LocalizedStringResource(stringLiteral: "Weight"))
                StatItem(value: LocalizedStringResource(stringLiteral: height), title: LocalizedStringResource(stringLiteral: "Height"))
                StatItem(value: LocalizedStringResource(stringLiteral: activityLevel), title: LocalizedStringResource(stringLiteral: "Activity Level"))
            }
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

