//
//  UDPlan.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 21.10.2024.
//

import Foundation

// MARK: - UserDefaults Manager
final class UDPlan {
    
    static let shared = UDPlan()
    private let defaults = UserDefaults.standard
    private let planKey = "plans"
    
    // MARK: - Private Init
    private init() {}
    
    func savePlan(_ plan: WeeklyTrainingPlan) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(plan)
        defaults.set(data, forKey: planKey)
    }
    
    func fetchPlan() throws -> WeeklyTrainingPlan? {
        guard let data = defaults.data(forKey: planKey) else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(WeeklyTrainingPlan.self, from: data)
    }
    
    func updatePlan(_ plan: WeeklyTrainingPlan) throws {
        try savePlan(plan)
    }
    
    func deletePlan() {
        defaults.removeObject(forKey: planKey)
    }
}
