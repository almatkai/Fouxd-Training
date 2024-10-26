//
//  UDWorkoutHistory.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import Foundation

class UDWorkoutHistory {
    
    static let shared = UDWorkoutHistory()
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let workoutHistoryKey = "workout_history"
    
    // MARK: - Private Init
    private init() {}
    
    // MARK: - Private Helper Methods
    
    /// Get all workout histories from UserDefaults
    private func getAllWorkouts() -> [WorkoutHistory] {
        guard let data = defaults.data(forKey: workoutHistoryKey),
              let workouts = try? JSONDecoder().decode([WorkoutHistory].self, from: data) else {
            return []
        }
        return workouts
    }
    
    /// Save all workout histories to UserDefaults
    private func saveAllWorkouts(_ workouts: [WorkoutHistory]) throws {
        let data = try JSONEncoder().encode(workouts)
        defaults.set(data, forKey: workoutHistoryKey)
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new workout history entry
    func create(history: WorkoutHistory) throws {
        var workouts = getAllWorkouts()
        workouts.append(history)
        try saveAllWorkouts(workouts)
    }
    
    /// Retrieve a specific workout history entry
    func read(id: UUID) -> WorkoutHistory? {
        let workouts = getAllWorkouts()
        return workouts.first { $0.id == id }
    }
    
    /// Retrieve all workout history entries
    func readAll() -> [WorkoutHistory] {
        return getAllWorkouts()
    }
    
    /// Retrieve workout history entries within a date range
    func readRange(from startDate: Date, to endDate: Date) -> [WorkoutHistory] {
        let workouts = getAllWorkouts()
        return workouts.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    /// Update an existing workout history entry
    func update(id: UUID, history: WorkoutHistory) throws {
        var workouts = getAllWorkouts()
        guard let index = workouts.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "UDWorkoutHistory", code: 404,
                         userInfo: [NSLocalizedDescriptionKey: "Workout history not found"])
        }
        
        workouts[index] = history
        try saveAllWorkouts(workouts)
    }
    
    /// Delete a workout history entry
    func delete(id: UUID) throws {
        var workouts = getAllWorkouts()
        workouts.removeAll { $0.id == id }
        try saveAllWorkouts(workouts)
    }
    
    /// Delete multiple workout history entries
    func deleteBatch(ids: [UUID]) throws {
        var workouts = getAllWorkouts()
        workouts.removeAll { ids.contains($0.id) }
        try saveAllWorkouts(workouts)
    }
    
    /// Delete all workout history entries before a specific date
    func deleteBeforeDate(_ date: Date) throws {
        var workouts = getAllWorkouts()
        workouts.removeAll { $0.date < date }
        try saveAllWorkouts(workouts)
    }
}

// MARK: - Query Extensions
extension UDWorkoutHistory {
    /// Retrieve completed workout history entries
    func readCompleted() -> [WorkoutHistory] {
        let workouts = getAllWorkouts()
        return workouts.filter { $0.isCompleted }
    }
    
    /// Retrieve incomplete workout history entries
    func readIncomplete() -> [WorkoutHistory] {
        let workouts = getAllWorkouts()
        return workouts.filter { !$0.isCompleted }
    }
    
    /// Get workout completion statistics for a date range
    func getStatistics(from startDate: Date, to endDate: Date) -> (total: Int, completionRate: Double) {
        let histories = readRange(from: startDate, to: endDate)
        let completed = histories.filter { $0.isCompleted }.count
        let total = histories.count
        let completionRate = total > 0 ? Double(completed) / Double(total) * 100 : 0
        
        return (total, completionRate)
    }
    
    /// Get latest workout
    func getLatestWorkout() -> WorkoutHistory? {
        let workouts = getAllWorkouts()
        return workouts.sorted { $0.date > $1.date }.first
    }
    
    /// Clear all workout history data
    func clearAll() {
        defaults.removeObject(forKey: workoutHistoryKey)
    }
}

// MARK: - Backup and Restore
extension UDWorkoutHistory {
    /// Export all workout history data
    func exportData() throws -> Data {
        let workouts = getAllWorkouts()
        return try JSONEncoder().encode(workouts)
    }
    
    /// Import workout history data
    func importData(_ data: Data, merge: Bool = false) throws {
        let importedWorkouts = try JSONDecoder().decode([WorkoutHistory].self, from: data)
        
        if merge {
            var existingWorkouts = getAllWorkouts()
            existingWorkouts.append(contentsOf: importedWorkouts)
            try saveAllWorkouts(existingWorkouts)
        } else {
            try saveAllWorkouts(importedWorkouts)
        }
    }
}
