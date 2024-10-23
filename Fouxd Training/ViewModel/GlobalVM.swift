//
//  GlobalVM.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI
import FirebaseAuth

class GlobalVM: ObservableObject {
    @Published var screenWidth: CGFloat
    @Published var screenHeight: CGFloat
    @Published var userSession: User?
    @Published var userData: UserData = UserData()
    @Published var plans: [Plan] = []
    
    init() {
        self.screenWidth = UIScreen.main.bounds.width
        self.screenHeight = UIScreen.main.bounds.height
    }
    
    func refreshUser() {
        userSession = Auth.auth().currentUser
    }
    
    func saveUserData() async {
        if let user = userSession {
            FBMUserData.shared.createUserData(uid: user.uid, data: userData)
            plans = PlanMakerService.shared.createPlan(userData: userData)
            do {
                try await FBMPlan.shared.savePlan(.init(plans: plans), userId: user.uid)
                print("Plan saved successfully.")
            } catch {
                print("Failed to save plan: \(error.localizedDescription)")
            }
        } else {
            UDUserData.shared.saveUserDataLocally(data: userData)
            plans = PlanMakerService.shared.createPlan(userData: userData)
            do {
                try UDPlan.shared.savePlan(.init(plans: plans))
                print("Plan saved successfully.")
            } catch {
                print("Failed to save plan: \(error.localizedDescription)")
            }
        }
    }
}
