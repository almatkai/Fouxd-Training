//
//  FirstLaunchSetupView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct FirstLaunchSetupView: View {
    
    @EnvironmentObject private var globalVM: GlobalVM
    @State var pageCounter = 0
    
    var body: some View {
        switch pageCounter {
        case 0:
            FirstView(pageCounter: $pageCounter)
        case 1:
            SecondView(pageCounter: $pageCounter)
        default:
            EmptyView()
        }
            
    }
    
    struct FirstView: View {
        
        @EnvironmentObject private var globalVM: GlobalVM
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
                            .foregroundStyle(Color(hex: "#3B2645"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Text("Log in to your personal account to save your progress")
                            .font(.title3)
                    }.padding(32)
                    Spacer()
                }
                VStack {
                    Spacer()
                    Button(action: {
                        print("Sign in")
                    }) {
                        HStack {
                            HStack {
                                Image("google")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                Text("Sign in with Google")
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(30)
                        .frame(maxWidth: globalVM.screenWidth * 0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    
                    Button(action: {
                        withAnimation{
                            pageCounter += 1
                        }
                    }) {
                        HStack {
                            HStack {
                                Text("Continue without account")
                                    .foregroundStyle(Color(hex: "#AB8DA8"))
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(Color(hex: "#AB8DA8"))
                            }
                            .padding()
                        }
                        .background(Color.white)
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
}

struct SecondView: View {
    @EnvironmentObject private var globalVM: GlobalVM
    @Binding var pageCounter: Int
    
    @State var user = UserModel()
    @State var pickerType: PickerType = .weight
    
    var body: some View {
        ZStack {
            VStack {
                Image("second_screen")
                    .resizable()
                    .scaledToFit()
                    .offset(y: -globalVM.screenHeight * 0.05)
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                    )
                Spacer()
            }
            VStack {
                Spacer()
                
                HStack {
                    VStack {
                        Spacer()
                        ForEach(PickerType.allCases, id: \.self) { type in
                            buttonWithBackground(for: type)
                        }
                    }
                    .frame(width: globalVM.screenWidth * 0.56)

                    VStack {
                        Spacer()
                        pickerView()
                            .frame(width: globalVM.screenWidth * 0.34)
                    }
                }.padding(32)
                
                navigationButtons()
                    .padding()
                    .padding(.bottom, 42)
            }
        }
    }
    
    enum PickerType: String, CaseIterable {
        case weight = "Weight"
        case height = "Height"
        case age = "Age"
        case gender = "Gender"
        case freeDays = "Free Days"
        case freeHours = "Free Hours"
        case activityLevel = "Activity Level"
        case goal = "Goal"
    }
    
    private func buttonWithBackground(for type: PickerType) -> some View {
        ZStack(alignment: .leading) {
            if pickerType == type {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.2))
                    .matchedGeometryEffect(id: "background", in: animation)
            }
            button(for: type)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut, value: pickerType)
    }
    
    @Namespace private var animation
    
    private func button(for type: PickerType, text: String? = nil) -> some View {
        Button(action: {
            withAnimation {
                pickerType = type
            }
        }) {
            Text(text ?? buttonText(for: type))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(pickerType == type ? .headline : .body)
                .fontWeight(pickerType == type ? .heavy : .medium)
        }
        .foregroundColor(pickerType == type ? .blue : .black)
    }
    
    private func buttonText(for type: PickerType) -> String {
        switch type {
        case .weight:
            return String(format: "Weight: %.1f kg", user.weight)
        case .height:
            return "Height: \(Int(user.height)) cm"
        case .age:
            return "Age: \(user.age) years"
        case .gender:
            return "Gender: \(user.gender == .male ? "Male" : user.gender == .female ? "Female" : "Other")"
        case .freeDays:
            return "Free Days: \(user.freeDays)"
        case .freeHours:
            return String(format: "Free Hours: %.1f hrs", user.freeHour)
        case .activityLevel:
            return "Activity Level: \(user.activityLevel)"
        case .goal:
            return "Goal: \(user.goal)"
        }
    }
    
    private func pickerView() -> some View {
        Group {
            switch pickerType {
            case .weight:
                Picker("Weight", selection: $user.weight) {
                    ForEach(30...150, id: \.self) { weight in
                        Text("\(weight) kg").tag(Double(weight))
                            .font(.callout)
                    }
                }
            case .height:
                Picker("Height", selection: $user.height) {
                    ForEach(100...250, id: \.self) { height in
                        Text("\(height) cm").tag(Double(height)).font(.callout)
                    }
                }
            case .age:
                Picker("Age", selection: $user.age) {
                    ForEach(1...100, id: \.self) { age in
                        Text("\(age) years").tag(age).font(.callout)
                    }
                }
            case .gender:
                Picker("Gender", selection: $user.gender) {
                    Text("Male").tag(Gender.male).font(.callout)
                    Text("Female").tag(Gender.female).font(.callout)
                    Text("Other").tag(Gender.other).font(.callout)
                }
            case .freeDays:
                Picker("Free Days", selection: $user.freeDays) {
                    ForEach(0...7, id: \.self) { day in
                        Text("\(day) days").tag(day).font(.callout)
                    }
                }
            case .freeHours:
                Picker("Free Hours", selection: $user.freeHour) {
                    ForEach(Array(stride(from: 0.0, through: 24.0, by: 0.5)), id: \.self) { hour in
                        Text("\(hour, specifier: "%.1f") hrs").tag(hour).font(.callout)
                    }
                }
            case .activityLevel:
                Picker("Activity Level", selection: $user.activityLevel) {
                    Text("Sedentary").tag(ActivityLevel.sedentary).font(.callout)
                    Text("Light").tag(ActivityLevel.light).font(.callout)
                    Text("Moderate").tag(ActivityLevel.moderate).font(.callout)
                    Text("Active").tag(ActivityLevel.active).font(.callout)
                }
            case .goal:
                Picker("Goal", selection: $user.goal) {
                    Text("Weight Loss").tag(FitnessGoal.weightLoss).font(.callout)
                    Text("Muscle Gain").tag(FitnessGoal.muscleGain).font(.callout)
                    Text("Endurance").tag(FitnessGoal.endurance).font(.callout)
                }
            }
        }
        .pickerStyle(WheelPickerStyle())
        .padding()
    }
    
    private func navigationButtons() -> some View {
        HStack {
            navigationButton(action: { pageCounter -= 1 }, imageName: "chevron.left.circle.fill")
            Spacer()
            navigationButton(action: {
                goToNextPickerType()
            }, imageName: "chevron.right.circle.fill")
        }
    }
    
    private func navigationButton(action: @escaping () -> Void, imageName: String) -> some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundStyle(Color(hex: "#AB8DA8"))
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(hex: "#AB8DA8"), lineWidth: 2)
                )
        }
        .frame(maxWidth: globalVM.screenWidth * 0.8)
    }
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    private func goToNextPickerType() {
        if let currentIndex = PickerType.allCases.firstIndex(of: pickerType),
           currentIndex < PickerType.allCases.count - 1 {
            pickerType = PickerType.allCases[currentIndex + 1]
        } else {
            withAnimation {
                isFirstLaunch = false
            }
        }
    }
}
