//
//  PlanViewModel.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import Foundation
import FirebaseAuth
import Combine

class PlanViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    
    var plansPublisher: AnyPublisher<[Plan], Never> {
        $plans.eraseToAnyPublisher()
    }
    
    func createPlans(userData: UserData) {
        plans = PlanMakerService.shared.createPlan(userData: userData)
    }
    
    func checkAndCreatePlans(userData: UserData, userId: String) async {
        let tempPlans = PlanMakerService.shared.createPlan(userData: userData)
        do {
            plans = try await FBMPlan.shared.checkAndCreatePlan(userId: userId, defaultPlan: .init(plans: tempPlans)).plans
        } catch {
            print("ERROR IN checkAndCreatePlans(): \(error.localizedDescription)")
        }
    }
    
    func isPlanExist(userData: UserData, userId: String) async -> Bool {
        let tempPlans = PlanMakerService.shared.createPlan(userData: userData)
        do {
            let plans = try await FBMPlan.shared.isPlanExist(userId: userId, defaultPlan: .init(plans: tempPlans))?.plans
            if let plans = plans {
                self.plans = plans
                return true
            } else {
                return false
            }
        } catch {
            print("ERROR IN isPlanExist(): \(error.localizedDescription)")
            return false
        }
    }

    func savePlans(userSession: User?) {
        if let user = userSession {
            FBMPlan.shared.savePlan(.init(plans: plans), userId: user.uid) { error in
                if let error = error {
                    print("Error saving plan: \(error)")
                } else {
                    print("Plan saved successfully")
                }
            }
        } else {
            do {
                try UDPlan.shared.savePlan(.init(plans: plans))
                print("Plan saved successfully to UD.")
            } catch {
                print("Failed to save plan to UD: \(error.localizedDescription)")
            }
        }
    }

    func fetchPlans(userSession: User?) {
        if let user = userSession {
            FBMPlan.shared.fetchPlan(userId: user.uid) { result in
                switch result {
                case .success(let plan):
                    self.plans = plan?.plans ?? []
                case .failure(let error):
                    print("Error fetching plans FB: \(error)")
                }
            }
        } else {
            do {
                self.plans = try UDPlan.shared.fetchPlan()?.plans ?? []
            } catch {
                print("Error fetching plans UD: \(error.localizedDescription)")
            }
        }
    }
}
