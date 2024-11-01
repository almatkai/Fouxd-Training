//
//  WorkoutHistory.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import Foundation
import FirebaseFirestore

// MARK: - History Models
struct WorkoutHistory: Identifiable, Codable {
    @DocumentID var id: String?
    let user_id: String?
    let date: Date
    let duration: TimeInterval
    let exercisesCompleted: Int
    let totalExercises: Int
    let isCompleted: Bool
    
    var completionPercentage: Double {
        if totalExercises == 0 { return 0 }
        return Double(exercisesCompleted) / Double(totalExercises) * 100
    }
}
