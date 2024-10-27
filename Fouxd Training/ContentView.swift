//
//  ContentView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 15.10.2024.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @EnvironmentObject private var planVM: PlanViewModel
    @EnvironmentObject private var userDataVM: UserDataViewModel
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @EnvironmentObject private var workoutHistoryVM: WorkoutHistoryViewModel
    
    var body: some View {
        VStack {
            if isFirstLaunch {
                FirstLaunchSetupView()
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))
            } else {
                MainView()
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        setup()
                    }
            }
        }
    }
    
    private func setup() {
        userSessionVM.refreshUser()
        userDataVM.fetchUserData(userSession: userSessionVM.userSession)
        planVM.fetchPlans(userSession: userSessionVM.userSession)
        workoutHistoryVM.fetchWorkoutHistory(userId: userSessionVM.userSession?.uid ?? "")
    }
}

