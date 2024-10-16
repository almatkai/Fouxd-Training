//
//  PlanModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

struct Plan {
    var daysPerWeek: Int
    var sessionDuration: Int // in minutes
    var focus: String
    var cardio: CardioPlan
    var strengthTraining: StrengthPlan
    var caloricAdjustment: String
}

struct CardioPlan {
    var intensity: Intensity
    var duration: Int // in minutes
    var frequency: Int // times per week
}

struct StrengthPlan {
    var focus: String
    var exercises: [String]
    var setsAndReps: String
}

enum Intensity {
    case low, medium, high
}
