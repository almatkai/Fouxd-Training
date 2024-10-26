//
//  ThirdLaunchView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 20.10.2024.
//

import SwiftUI

struct ThirdView: View {
    @EnvironmentObject private var userDataVM: UserDataViewModel
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @EnvironmentObject private var planVM: PlanViewModel
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @State private var selectedDay: Availability = Availability(weekDay: .monday, freeTime: 0)
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    @Binding var pageCounter: Int
    
    var body: some View {
        ZStack {
            VStack {
                Image("third_screen")
                    .resizable()
                    .scaledToFit()
                    .offset(y: -height() * 0.05)
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                    )
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Spacer()
                    Text("Create your timetable")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.cpurple))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(.bold)
                        .padding(.vertical)
                    
                    Text("Select the days and times you're available for training")
                        .foregroundStyle(Color(.cpurple))
                }.padding(.horizontal, 48)
                
                HStack {
                    VStack {
                        ForEach(userDataVM.userData.availibility, id: \.self) { day in
                            dayButtonWithBackground(for: day)
                        }
                    }
                    .frame(width: width() * 0.58)
                    
                    timePickerView()
                        .frame(width: width() * 0.34)
                    
                }.padding(.horizontal, 32)
                
                navigationButtons()
                    .padding(8)
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Initialize with the first day's time
            if let firstDay = userDataVM.userData.availibility.first {
                updateSelectedTimeFromAvailability()
            }
        }
    }
    
    private func updateSelectedTimeFromAvailability() {
        // Convert hour and minute to freeTime (e.g., 9.5 -> 9:30)
        selectedHour = Int(floor(selectedDay.freeTime))
        selectedMinute = Int((selectedDay.freeTime.truncatingRemainder(dividingBy: 1) * 60).rounded() / 15) * 15
    }
    
    private func updateAvailabilityTime() {
        if let index = userDataVM.userData.availibility.firstIndex(where: { $0.weekDay == selectedDay.weekDay }) {
            // Convert hour and minute to freeTime (e.g., 9:30 -> 9.5)
            let freeTime = Double(selectedHour) + (Double(selectedMinute) / 60.0)
            userDataVM.userData.availibility[index].freeTime = freeTime
        }
    }
    
    @Namespace private var animation
    
    private func dayButtonWithBackground(for availability: Availability) -> some View {
        ZStack(alignment: .leading) {
            if availability.weekDay == selectedDay.weekDay  {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.2))
                    .matchedGeometryEffect(id: "background", in: animation)
            }
            dayButton(for: availability)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut, value: selectedDay)
    }
    
    private func dayButton(for availability: Availability) -> some View {
        Button(action: {
            withAnimation {
                selectedDay = availability 
                updateSelectedTimeFromAvailability()
            }
        }) {
            HStack {
                Text(availability.weekDay.rawValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(selectedDay.weekDay == availability.weekDay ? .headline : .body)
                    .fontWeight(selectedDay.weekDay == availability.weekDay ? .heavy : .medium)
                
                // Convert freeTime to hour:minute format
                let hour = Int(floor(availability.freeTime))
                let minute = Int((availability.freeTime.truncatingRemainder(dividingBy: 1) * 60).rounded())
                Text(String(format: "%02d:%02d", hour, minute))
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(selectedDay.weekDay == availability.weekDay ? .blue : .secondary)
    }
    
    private func timePickerView() -> some View {
        HStack {
            Picker("Hours", selection: $selectedHour) {
                ForEach(0...23, id: \.self) { hour in
                    Text(String(format: "%02d", hour)).tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: width() * 0.15)
            .padding(0)
            .onChange(of: selectedHour) { _ in
                updateAvailabilityTime()
            }
            
            Text(":")
                .font(.title2)
                .fontWeight(.bold)
            
            Picker("Minutes", selection: $selectedMinute) {
                ForEach(Array(stride(from: 0, to: 59, by: 15)), id: \.self) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: width() * 0.15)
            .padding(0)
            .onChange(of: selectedMinute) { _ in
                updateAvailabilityTime()
            }
        }
        .padding()
    }
    
    private func navigationButtons() -> some View {
        HStack {
            NavigationButton(action: {
                goBackToPrevious()
            }, imageName: "chevron.left.circle.fill", width: width() * 0.4)
            Spacer()
            NavigationButton(action: {
                Task {
                    await goToNext()
                }
            }, imageName: "chevron.right.circle.fill", width: width() * 0.4)
        }
    }
    
    private func goBackToPrevious() {
        let index = userDataVM.userData.availibility.firstIndex { $0.weekDay == selectedDay.weekDay }
        if let currentIndex = index, currentIndex > 0 {
            selectedDay = userDataVM.userData.availibility[currentIndex - 1]
            updateSelectedTimeFromAvailability()
        } else {
            pageCounter -= 1
        }
    }
    
    private func goToNext() async {
        let index = userDataVM.userData.availibility.firstIndex { $0.weekDay == selectedDay.weekDay }
        if let currentIndex = index, currentIndex < userDataVM.userData.availibility.count - 1 {
            selectedDay = userDataVM.userData.availibility[currentIndex + 1]
            updateSelectedTimeFromAvailability()
        } else {
            await createAccount()
            isFirstLaunch = false
        }
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
