//
//  FMBWorkoutHistory.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import Foundation
import FirebaseFirestore

class FBMWorkoutHistory {
    
    static let shared = FBMWorkoutHistory()
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let collection = "workout_history"
    
    // MARK: - Private Init
    private init() {}
    
    // MARK: - CRUD Operations
    
    /// Create a new workout history entry
    func create(history: WorkoutHistory) async throws {
        let document = db.collection(collection).document()
        try document.setData(from: history)
    }
    
    /// Retrieve a specific workout history entry
    func read(id: String, userId: String) async throws -> WorkoutHistory? {
        let document = try await db.collection(collection)
            .document()
            .getDocument()
        
        let history = try? document.data(as: WorkoutHistory.self)
        return history?.user_id == userId ? history : nil
    }
    
    /// Retrieve all workout history entries for a specific user
    func readAll(userId: String) async throws -> [WorkoutHistory] {
        let snapshot = try await db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: WorkoutHistory.self)
        }
    }
    
    /// Retrieve workout history entries within a date range for a specific user
    func readRange(from startDate: Date, to endDate: Date, userId: String) async throws -> [WorkoutHistory] {
        let snapshot = try await db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: WorkoutHistory.self)
        }
    }
    
    /// Update an existing workout history entry
    func update(id: String, history: WorkoutHistory, userId: String) async throws {
        // Verify the workout belongs to the user before updating
        guard let existingHistory = try await read(id: id, userId: userId) else {
            throw NSError(domain: "FBMWorkoutHistory", code: 403,
                         userInfo: [NSLocalizedDescriptionKey: "Unauthorized access to workout history"])
        }
        
        try await db.collection(collection).document(id).setData(from: history)
    }
    
    /// Delete a workout history entry
    func delete(id: String, userId: String) async throws {
        // Verify the workout belongs to the user before deleting
        guard let _ = try await read(id: id, userId: userId) else {
            throw NSError(domain: "FBMWorkoutHistory", code: 403,
                         userInfo: [NSLocalizedDescriptionKey: "Unauthorized access to workout history"])
        }
        
        try await db.collection(collection).document(id).delete()
    }
    
    /// Delete multiple workout history entries for a specific user
    func deleteBatch(ids: [String], userId: String) async throws {
        let batch = db.batch()
        
        // Verify all workouts belong to the user before deleting
        for id in ids {
            guard let _ = try await read(id: id, userId: userId) else {
                throw NSError(domain: "FBMWorkoutHistory", code: 403,
                            userInfo: [NSLocalizedDescriptionKey: "Unauthorized access to workout history"])
            }
            let ref = db.collection(collection).document(id)
            batch.deleteDocument(ref)
        }
        
        try await batch.commit()
    }
    
    /// Delete all workout history entries before a specific date for a user
    func deleteBeforeDate(_ date: Date, userId: String) async throws {
        let snapshot = try await db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("date", isLessThan: date)
            .getDocuments()
        
        let batch = db.batch()
        snapshot.documents.forEach { document in
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
    }
}

// MARK: - Query Extensions
extension FBMWorkoutHistory {
    /// Retrieve completed workout history entries for a specific user
    func readCompleted(userId: String) async throws -> [WorkoutHistory] {
        let snapshot = try await db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("isCompleted", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: WorkoutHistory.self)
        }
    }
    
    /// Retrieve incomplete workout history entries for a specific user
    func readIncomplete(userId: String) async throws -> [WorkoutHistory] {
        let snapshot = try await db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("isCompleted", isEqualTo: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: WorkoutHistory.self)
        }
    }
    
    /// Get workout completion statistics for a date range for a specific user
    func getStatistics(from startDate: Date, to endDate: Date, userId: String) async throws -> (total: Int, completionRate: Double) {
        let histories = try await readRange(from: startDate, to: endDate, userId: userId)
        let completed = histories.filter { $0.isCompleted }.count
        let total = histories.count
        let completionRate = total > 0 ? Double(completed) / Double(total) * 100 : 0
        
        return (total, completionRate)
    }
    
    /// Get latest workout for a specific user
    func getLatestWorkout(userId: String) async throws -> WorkoutHistory? {
        let snapshot = try await db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.first.flatMap { document in
            try? document.data(as: WorkoutHistory.self)
        }
    }
}
