//
//  FBMPlan.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 21.10.2024.
//

import Foundation
import FirebaseFirestore

// MARK: - Firebase Manager
final class FBMPlan {
    
    static let shared = FBMPlan()
    private let db = Firestore.firestore()
    private let planCollection = "plans"

    // MARK: - Private Init
    private init() {}
    
    func checkAndCreatePlan(userId: String, defaultPlan: WeeklyTrainingPlan) async throws -> WeeklyTrainingPlan {
        let documentRef = db.collection(planCollection).document(userId)
        
        let document = try await documentRef.getDocument()
        
        if document.exists {
            return try document.data(as: WeeklyTrainingPlan.self)
        } else {
            try await savePlan(defaultPlan, userId: userId)
            return defaultPlan
        }
    }
    
    func isPlanExist(userId: String, defaultPlan: WeeklyTrainingPlan) async throws -> WeeklyTrainingPlan? {
        let documentRef = db.collection(planCollection).document(userId)
        
        let document = try await documentRef.getDocument()
        
        if document.exists {
            return try document.data(as: WeeklyTrainingPlan.self)
        } else {
            return nil
        }
    }
    
    func savePlan(_ plan: WeeklyTrainingPlan, userId: String) async throws {
        let documentRef = db.collection(planCollection).document(userId)
        try documentRef.setData(from: plan, merge: true)
    }
    
    func fetchPlan(userId: String, completion: @escaping (Result<WeeklyTrainingPlan?, Error>) -> Void) {
        let documentRef = db.collection(planCollection).document(userId)
        documentRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = documentSnapshot else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                return
            }

            do {
                let plan = try document.data(as: WeeklyTrainingPlan.self)
                completion(.success(plan))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updatePlan(_ plan: WeeklyTrainingPlan, userId: String) async throws {
        try await savePlan(plan, userId: userId)
    }
    
    func deletePlan(userId: String) async throws {
        let documentRef = db.collection(planCollection).document(userId)
        try await documentRef.delete()
    }
}
