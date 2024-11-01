//
//  TrainingSession.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import Foundation

// MARK: - Training Session Models
struct TrainingSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let exercises: [CompletedExercise]
    let totalCaloriesBurned: Double
    
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "N/A"
    }
}

struct CompletedExercise: Codable, Identifiable {
    let id: UUID
    let exercise: ExerciseWrapper
    let configuration: ExerciseConfiguration
    let completedSets: [CompletedSet]
    let startTime: Date
    let endTime: Date
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}

struct CompletedSet: Codable {
    let reps: Int
    let timestamp: Date
}
