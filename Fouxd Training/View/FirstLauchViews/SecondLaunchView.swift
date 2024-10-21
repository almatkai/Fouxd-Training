//
//  SecondLaunchView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 20.10.2024.
//

import SwiftUI

struct SecondLaunchView: View {
    @EnvironmentObject private var globalVM: GlobalVM
    @Binding var pageCounter: Int
    
    @State var pickerType: PickerType = .weight
    
    init(pageCounter: Binding<Int>) {
        _pageCounter = pageCounter
    }
    
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
                    .frame(width: globalVM.screenWidth * 0.58)

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
        case activityLevel = "Activity Level"
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
        .foregroundColor(pickerType == type ? .blue : .secondary)
    }
    
    private func buttonText(for type: PickerType) -> String {
        switch type {
        case .weight:
            return String(format: "Weight: %.1f kg", globalVM.userData.weight)
        case .height:
            return "Height: \(Int(globalVM.userData.height)) cm"
        case .age:
            return "Age: \(globalVM.userData.age) years"
        case .gender:
            return "Gender: \(globalVM.userData.gender == .male ? "Male" : globalVM.userData.gender == .female ? "Female" : "Other")"
        case .activityLevel:
            return "Activity Level: \(globalVM.userData.activityLevel)"
        }
    }
    
    private func pickerView() -> some View {
        Group {
            switch pickerType {
            case .weight:
                Picker("Weight", selection: $globalVM.userData.weight) {
                    ForEach(30...150, id: \.self) { weight in
                        Text("\(weight) kg").tag(Double(weight))
                            .font(.callout)
                    }
                }
            case .height:
                Picker("Height", selection: $globalVM.userData.height) {
                    ForEach(100...250, id: \.self) { height in
                        Text("\(height) cm").tag(Double(height)).font(.callout)
                    }
                }
            case .age:
                Picker("Age", selection: $globalVM.userData.age) {
                    ForEach(1...100, id: \.self) { age in
                        Text("\(age) years").tag(age).font(.callout)
                    }
                }
            case .gender:
                Picker("Gender", selection: $globalVM.userData.gender) {
                    Text("Male").tag(Gender.male).font(.callout)
                    Text("Female").tag(Gender.female).font(.callout)
                    Text("Other").tag(Gender.other).font(.callout)
                }
            case .activityLevel:
                Picker("Activity Level", selection: $globalVM.userData.activityLevel) {
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
    
    private func navigationButtons() -> some View {
        HStack {
            NavigationButton(action: {
                goBackToPreviousPickerType()
            }, imageName: "chevron.left.circle.fill", width: globalVM.screenWidth * 0.4)
            Spacer()
            NavigationButton(action: {
                goToNextPickerType()
            }, imageName: "chevron.right.circle.fill", width: globalVM.screenWidth * 0.4)
        }
    }
        
    private func goToNextPickerType() {
        if let currentIndex = PickerType.allCases.firstIndex(of: pickerType),
           currentIndex < PickerType.allCases.count - 1 {
            pickerType = PickerType.allCases[currentIndex + 1]
        } else {
            pageCounter += 1
        }
    }
    
    private func goBackToPreviousPickerType() {
        if let currentIndex = PickerType.allCases.firstIndex(of: pickerType),
           currentIndex > 0 {
            pickerType = PickerType.allCases[currentIndex - 1]
        } else {
            pageCounter -= 1
        }
    }
}
