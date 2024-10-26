//
//  HomeView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 17.10.2024.
//

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @EnvironmentObject private var planVM: PlanViewModel
    @EnvironmentObject private var userDataVM: UserDataViewModel
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    @State var plans: [Plan] = []
    var body: some View {
        NavigationStack {
            VStack {
                Text(userSessionVM.userSession?.uid ?? "NO USER ID")
                Button(action: {
                    isFirstLaunch = true
                    userDataVM.userData = UserData()
                }){
                    Text("RESET")
                }
                
                Button {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                } label: {
                    Text("Log Out")
                }
                
                Button(action: {
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                }){
                    Label("Delete User Default Information", systemImage: "trash")
                }
                
                Button(action: {
                    planVM.plans = PlanMakerService.shared.createPlan(userData: userDataVM.userData)
                }){
                    Label("Add Workout", systemImage: "plus")
                }
                
                Button(action: {
                    userSessionVM.refreshUser()
                }){
                    Label("Refresh User", systemImage: "arrow.clockwise")
                }
                
            }
        }
    }
}

