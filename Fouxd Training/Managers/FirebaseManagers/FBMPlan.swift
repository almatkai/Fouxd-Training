//
//  FBMPlan.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 21.10.2024.
//

import Foundation
import FirebaseFirestore

// MARK: - Firebase Manager
final class FBMPlan {
    static let shared = FBMPlan()
    private let db = Firestore.firestore()
    private let planCollection = "plans"

    private init() {}
    
    func savePlan(_ plan: WeeklyTrainingPlan, userId: String) async throws {
        let documentRef = db.collection(planCollection).document(userId)
        try documentRef.setData(from: plan, merge: true)
    }
    
    func fetchPlan(userId: String) async throws -> Plan? {
        let documentRef = db.collection(planCollection).document(userId)
        let document = try await documentRef.getDocument()
        return try? document.data(as: Plan.self)
    }
    
    func updatePlan(_ plan: WeeklyTrainingPlan, userId: String) async throws {
        try await savePlan(plan, userId: userId)
    }
    
    func deletePlan(userId: String) async throws {
        let documentRef = db.collection(planCollection).document(userId)
        try await documentRef.delete()
    }
}
