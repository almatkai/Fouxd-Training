//
//  UDPlan.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 21.10.2024.
//

import Foundation

// MARK: - UserDefaults Manager
final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    private let planKey = "userWorkoutPlan"
    
    private init() {}
    
    func savePlan(_ plan: Plan) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(plan)
        defaults.set(data, forKey: planKey)
    }
    
    func fetchPlan() throws -> Plan? {
        guard let data = defaults.data(forKey: planKey) else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(Plan.self, from: data)
    }
    
    func updatePlan(_ plan: Plan) throws {
        try savePlan(plan)
    }
    
    func deletePlan() {
        defaults.removeObject(forKey: planKey)
    }
}
