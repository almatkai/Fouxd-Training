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
                        .background(Color.white) // White background for the button
                        .foregroundColor(.blue) // Blue text color
                        .cornerRadius(30)
                        .frame(maxWidth: globalVM.screenWidth * 0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 2) // Blue border
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
    @State private var buttonFrames: [PickerType: CGRect] = [:]
    
    var body: some View {
        ZStack {
            VStack {
                Image("second_screen")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                HStack {
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .topLeading) {
                            // Highlight RoundedRectangle
                            if let frame = buttonFrames[pickerType] {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: frame.width, height: frame.height)
                                    .position(x: frame.midX, y: frame.midY)
                                    .animation(.easeInOut, value: pickerType)
                            }
                            
                            VStack {
                                // Button List
                                button(for: .weight, text: "Weight: \(user.weight, specifier: "%.1f") kg")
                                button(for: .height, text: "Height: \(user.height, specifier: "%.0f") cm")
                                button(for: .age, text: "Age: \(user.age) years")
                                button(for: .gender, text: "Gender: \(user.gender == .male ? "Male" : user.gender == .female ? "Female" : "Other")")
                                button(for: .freeDays, text: "Free Days: \(user.freeDays)")
                                button(for: .freeHours, text: "Free Hours: \(user.freeHour, specifier: "%.1f") hrs")
                                button(for: .activityLevel, text: "Activity Level: \(String(describing: user.activityLevel))")
                                button(for: .goal, text: "Goal: \(String(describing: user.goal))")
                            }
                            .background(GeometryReader { proxy in
                                Color.clear.onAppear {
                                    // Capture frames for all buttons
                                    for picker in PickerType.allCases {
                                        if let view = proxy[picker] {
                                            buttonFrames[picker] = geometry[view]
                                        }
                                    }
                                }
                            })
                        }
                    }
                    
                    
                    Spacer()

                    switch pickerType {
                    case .weight:
                        Picker("Weight", selection: $user.weight) {
                            ForEach(30...150, id: \.self) { weight in
                                Text("\(weight) kg").tag(Double(weight))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .height:
                        Picker("Height", selection: $user.height) {
                            ForEach(100...250, id: \.self) { height in
                                Text("\(height) cm").tag(Double(height))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .age:
                        Picker("Age", selection: $user.age) {
                            ForEach(1...100, id: \.self) { age in
                                Text("\(age) years").tag(age)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .gender:
                        Picker("Gender", selection: $user.gender) {
                            Text("Male").tag(Gender.male)
                            Text("Female").tag(Gender.female)
                            Text("Other").tag(Gender.other)
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .freeDays:
                        Picker("Free Days", selection: $user.freeDays) {
                            ForEach(0...7, id: \.self) { day in
                                Text("\(day) days").tag(day)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .freeHours:
                        Picker("Free Hours", selection: $user.freeHour) {
                            ForEach(Array(stride(from: 0.0, through: 24.0, by: 0.5)), id: \.self) { hour in
                                Text("\(hour, specifier: "%.1f") hrs").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .activityLevel:
                        Picker("Activity Level", selection: $user.activityLevel) {
                            Text("Sedentary").tag(ActivityLevel.sedentary)
                            Text("Light").tag(ActivityLevel.light)
                            Text("Moderate").tag(ActivityLevel.moderate)
                            Text("Active").tag(ActivityLevel.active)
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                    case .goal:
                        Picker("Goal", selection: $user.goal) {
                            Text("Weight Loss").tag(FitnessGoal.weightLoss)
                            Text("Muscle Gain").tag(FitnessGoal.muscleGain)
                            Text("Endurance").tag(FitnessGoal.endurance)
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                    }

                }.padding(32)
                
                HStack {
                    Button(action: {
                        withAnimation{
                            pageCounter -= 1
                        }
                    }) {
                        HStack {
                            HStack {
                                Image(systemName: "chevron.left.circle.fill")
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
                    Spacer()
                    Button(action: {
                        withAnimation{
                            pageCounter += 1
                        }
                    }) {
                        HStack {
                            HStack {
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
                }
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
}
