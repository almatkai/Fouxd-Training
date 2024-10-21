//
//  HomeView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 17.10.2024.
//

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @EnvironmentObject private var globalVM: GlobalVM
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    @State var plans: [Plan] = []
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isFirstLaunch = true
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
                    globalVM.plans = PlanMakerService.shared.determinePlanType(for: globalVM.userData, userId: globalVM.userSession?.uid ?? "")
                }){
                    Label("Add Workout", systemImage: "plus")
                }
            }
        }
    }
}

