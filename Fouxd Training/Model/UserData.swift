//
//  UserModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation
import FirebaseAuth

struct UserData: Codable {
    var id: UUID = UUID()
    var weight: Double = 62
    var height: Double = 175
    var age: Int = 18
    var gender: Gender = .male
    var availibility: [Availability] = [.init(weekDay: .monday, freeTime: 0.0), .init(weekDay: .tuesday, freeTime: 0.0), .init(weekDay: .wednesday, freeTime: 0.0), .init(weekDay: .thursday, freeTime: 0.0), .init(weekDay: .friday, freeTime: 0.0), .init(weekDay: .saturday, freeTime: 0.0), .init(weekDay: .sunday, freeTime: 0.0)]
    var activityLevel: ActivityLevel = .moderate
    var goal: FitnessGoal = .endurance
    var lastUpdated: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id, weight, height, age, gender, activityLevel, goal, availibility
    }
}

struct Availability: Codable, Hashable {
    var weekDay: WeekDay
    var freeTime: Double
    
    enum CodingKeys: String, CodingKey {
        case weekDay, freeTime
    }
}

enum WeekDay: Codable, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var rawValue: String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
}


enum Gender: Codable {
    case male, female, other
}

enum ActivityLevel: Codable {
    case sedentary, light, moderate, active
    
    var rawValue: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .light:
            return "Light"
        case .moderate:
            return "Moderate"
        case .active:
            return "Active"
        }
    }
    
    var duration: SessionType {
        switch self {
        case .sedentary:
            return .repsAndSets(reps: 120, sets: 3, rest: 30)
        case .light:
            return .repsAndSets(reps: 90, sets: 4, rest: 30)
        case .moderate:
            return .repsAndSets(reps: 60, sets: 3, rest: 30)
        case .active:
            return .repsAndSets(reps: 30, sets: 3, rest: 30)
        }
    }
}

enum FitnessGoal: Codable {
    case weightLoss, muscleGain, endurance
}
