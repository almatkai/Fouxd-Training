//
//  WorkoutHistory.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import Foundation

// MARK: - History Models
struct WorkoutHistory: Identifiable, Codable {
    let id: UUID
    let user_id: String?
    let date: Date
    let duration: TimeInterval
    let exercisesCompleted: Int
    let totalExercises: Int
    let isCompleted: Bool
    
    var completionPercentage: Double {
        Double(exercisesCompleted) / Double(totalExercises) * 100
    }
}
