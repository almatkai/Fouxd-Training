//
//  FMBWorkoutHistory.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
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
    func create(history: WorkoutHistory, completion: @escaping (Result<Void, Error>) -> Void) {
        let document = db.collection(collection).document()
        do {
            try document.setData(from: history) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    /// Retrieve a specific workout history entry
    func read(id: String, userId: String, completion: @escaping (Result<WorkoutHistory?, Error>) -> Void) {
        db.collection(collection).document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document else {
                completion(.success(nil))
                return
            }

            do {
                let history = try document.data(as: WorkoutHistory.self)
                if history.user_id == userId {
                    completion(.success(history))
                } else {
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Retrieve all workout history entries for a specific user
    func readAll(userId: String, completion: @escaping (Result<[WorkoutHistory], Error>) -> Void) {
        db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let histories = try snapshot?.documents.compactMap { document in
                        try document.data(as: WorkoutHistory.self)
                    } ?? []
                    completion(.success(histories))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Retrieve workout history entries within a date range for a specific user
    func readRange(from startDate: Date, to endDate: Date, userId: String, completion: @escaping (Result<[WorkoutHistory], Error>) -> Void) {
        db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let histories = try snapshot?.documents.compactMap { document in
                        try document.data(as: WorkoutHistory.self)
                    } ?? []
                    completion(.success(histories))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Update an existing workout history entry
    func update(id: String, history: WorkoutHistory, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        read(id: id, userId: userId) { result in
            switch result {
            case .success(let existingHistory):
                guard existingHistory != nil else {
                    completion(.failure(NSError(domain: "FBMWorkoutHistory", code: 403,
                                               userInfo: [NSLocalizedDescriptionKey: "Unauthorized access to workout history"])))
                    return
                }

                do {
                    try self.db.collection(self.collection).document(id).setData(from: history) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Delete a workout history entry
    func delete(id: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        read(id: id, userId: userId) { result in
            switch result {
            case .success(let existingHistory):
                guard existingHistory != nil else {
                    completion(.failure(NSError(domain: "FBMWorkoutHistory", code: 403,
                                               userInfo: [NSLocalizedDescriptionKey: "Unauthorized access to workout history"])))
                    return
                }

                self.db.collection(self.collection).document(id).delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Delete multiple workout history entries for a specific user
    func deleteBatch(ids: [String], userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let batch = db.batch()
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            read(id: id, userId: userId) { result in
                switch result {
                case .success(let existingHistory):
                    guard existingHistory != nil else {
                        completion(.failure(NSError(domain: "FBMWorkoutHistory", code: 403,
                                                   userInfo: [NSLocalizedDescriptionKey: "Unauthorized access to workout history"])))
                        return
                    }

                    let ref = self.db.collection(self.collection).document(id)
                    batch.deleteDocument(ref)
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    /// Delete all workout history entries before a specific date for a user
    func deleteBeforeDate(_ date: Date, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("date", isLessThan: date)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let batch = self.db.batch()
                snapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
}

// MARK: - Query Extensions
extension FBMWorkoutHistory {
    /// Retrieve completed workout history entries for a specific user
    func readCompleted(userId: String, completion: @escaping (Result<[WorkoutHistory], Error>) -> Void) {
        db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("isCompleted", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let histories = try snapshot?.documents.compactMap { document in
                        try document.data(as: WorkoutHistory.self)
                    } ?? []
                    completion(.success(histories))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Retrieve incomplete workout history entries for a specific user
    func readIncomplete(userId: String, completion: @escaping (Result<[WorkoutHistory], Error>) -> Void) {
        db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .whereField("isCompleted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let histories = try snapshot?.documents.compactMap { document in
                        try document.data(as: WorkoutHistory.self)
                    } ?? []
                    completion(.success(histories))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Get workout completion statistics for a date range for a specific user
    func getStatistics(from startDate: Date, to endDate: Date, userId: String, completion: @escaping (Result<(total: Int, completionRate: Double), Error>) -> Void) {
        readRange(from: startDate, to: endDate, userId: userId) { result in
            switch result {
            case .success(let histories):
                let completed = histories.filter { $0.isCompleted }.count
                let total = histories.count
                let completionRate = total > 0 ? Double(completed) / Double(total) * 100 : 0
                completion(.success((total, completionRate)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Get latest workout for a specific user
    func getLatestWorkout(userId: String, completion: @escaping (Result<WorkoutHistory?, Error>) -> Void) {
        db.collection(collection)
            .whereField("user_id", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let history = try snapshot?.documents.first.flatMap { document in
                        try document.data(as: WorkoutHistory.self)
                    }
                    completion(.success(history))
                } catch {
                    completion(.failure(error))
                }
            }
    }
}
