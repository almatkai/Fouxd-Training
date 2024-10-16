//
//  UserModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

struct UserModel {
    var id: UUID = UUID()
    var weight: Double = 62
    var height: Double = 175
    var age: Int = 18
    var gender: Gender = .male
    var freeDays: Int = 4
    var freeHour: Double = 1
    var activityLevel: ActivityLevel = .moderate
    var goal: FitnessGoal = .endurance
}

enum Gender {
    case male, female, other
}

enum ActivityLevel {
    case sedentary, light, moderate, active
}

enum FitnessGoal {
    case weightLoss, muscleGain, endurance
}
