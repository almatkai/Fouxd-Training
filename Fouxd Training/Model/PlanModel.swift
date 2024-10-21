//
//  PlanModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

struct Plan: Identifiable {
    var id = UUID()
    var userId: String
    var weekDay: WeekDay
    var exercises: [ExerciseSession]
}

enum SessionType {
    case repsAndSets(reps: Int, sets: Int, rest: Int)
    
    var reps: Int {
        switch self {
        case .repsAndSets(let reps, _, _):
            return reps
        }
    }
    
    var sets: Int {
        switch self {
        case .repsAndSets(_, let sets, _):
            return sets
        }
    }
    
    var rest: Int {
        switch self {
        case .repsAndSets(_, _, let rest):
            return rest
        }
    }
}

struct ExerciseSession: Identifiable {
    var id = UUID()
    var exercise: Exercise
    var sessionType: SessionType
}

protocol Exercise {
    var activityLevel: ActivityLevel { get }
    var title: String { get }
    var description: String { get }
}

enum UpperBodyExercises: String, Exercise {
    case pushUps = "pushUps"
    case tricepDips = "tricepDips"
    
    var activityLevel: ActivityLevel {
        switch self {
        case .pushUps:
            return .active
        case .tricepDips:
            return .moderate
        }
    }
    
    var title: String {
        switch self {
        case .pushUps:
            return "Push Ups"
        case .tricepDips:
            return "Tricep Dips"
        }
    }
    
    var description: String {
        switch self {
        case .pushUps:
            return "Push-ups are a great upper body exercise that target the chest, shoulders, and triceps."
        case .tricepDips:
            return "Tricep dips are a great upper body exercise that target the triceps and shoulders."
        }
    }
    
}

enum LowerBodyExercises: String, Exercise {
    case squats = "squats"
    case lunges = "lunges"
    case wallSit = "wallSit"
    case gluteBridge = "gluteBridge"
    
    var activityLevel: ActivityLevel {
        switch self {
        case .squats:
            return .moderate
        case .lunges, .gluteBridge:
            return .light
        case .wallSit:
            return .sedentary
        }
    }
    
    var title: String {
        switch self {
        case .squats:
            return "Squats"
        case .lunges:
            return "Lunges"
        case .wallSit:
            return "Wall Sit"
        case .gluteBridge:
            return "Glute Bridge"
        }
    }
    
    var description: String {
        switch self {
        case .squats:
            return "Squats are a great lower body exercise that target the quads, hamstrings, and glutes."
        case .lunges:
            return "Lunges are a great lower body exercise that target the quads, hamstrings, and glutes."
        case .wallSit:
            return "Wall sits are a great lower body exercise that target the quads and hamstrings."
        case .gluteBridge:
            return "Glute bridges are a great lower body exercise that target the glutes and hamstrings."
        }
    }

}

enum CoreExercises: String, Exercise, CaseIterable {
    case plank = "plank"
    case sitUps = "sitUps"
    case legRaises = "legRaises"
    case bicycleCrunches = "bicycleCrunches"
    
    var activityLevel: ActivityLevel {
        switch self {
        case .plank:
            return .moderate
        case .sitUps, .legRaises, .bicycleCrunches:
            return .light
        }
    }
    
    var title: String {
        switch self {
        case .sitUps:
            return "Sit Ups"
        case .plank:
            return "Plank"
        case .legRaises:
            return "Leg Raises"
        case .bicycleCrunches:
            return "Bicycle Crunches"
        }
    }
    
    var description: String {
        switch self {
        case .sitUps:
            return "Sit-ups are a great core exercise that target the abs and obliques."
        case .plank:
            return "Planks are a great core exercise that target the abs, obliques, and lower back."
        case .legRaises:
            return "Leg raises are a great core exercise that target the lower abs."
        case .bicycleCrunches:
            return "Bicycle crunches are a great core exercise that target the abs and obliques."
        }
    }
}

enum FullBodyExercises: String, Exercise {
    case burpees = "burpees"
    case mountainClimbers = "mountainClimbers"
    case jumpingJacks = "jumping"
    case highKnees = "highKnees"
    
    var activityLevel: ActivityLevel {
        switch self {
        case .burpees, .mountainClimbers:
            return .active
        case .highKnees:
            return .moderate
        case .jumpingJacks:
            return .sedentary
        }
    }
    
    var title: String {
        switch self {
        case .burpees:
            return "Burpees"
        case .jumpingJacks:
            return "Jumping Jacks"
        case .mountainClimbers:
            return "Mountain Climbers"
        case .highKnees:
            return "High Knees"
        }
    }
    
    var description: String {
        switch self {
        case .burpees:
            return "Burpees are a full body exercise that target the chest, shoulders, triceps, quads, hamstrings, and glutes."
        case .jumpingJacks:
            return "Jumping jacks are a great full body exercise that target the heart, legs, and arms."
        case .mountainClimbers:
            return "Mountain climbers are a great full body exercise that target the abs, shoulders, and legs."
        case .highKnees:
            return "High knees are a great cardio exercise that target the heart and legs."
        }
    }
}

// MARK: - Codable Extensions
extension Plan: Codable {
    enum CodingKeys: String, CodingKey {
        case id, userId, weekDay, exercises
    }
}

extension SessionType: Codable {
    enum CodingKeys: String, CodingKey {
        case reps, sets, rest
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reps, forKey: .reps)
        try container.encode(sets, forKey: .sets)
        try container.encode(rest, forKey: .rest)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reps = try container.decode(Int.self, forKey: .reps)
        let sets = try container.decode(Int.self, forKey: .sets)
        let rest = try container.decode(Int.self, forKey: .rest)
        self = .repsAndSets(reps: reps, sets: sets, rest: rest)
    }
}

extension ExerciseSession: Codable {
    enum CodingKeys: String, CodingKey {
        case id, exercise, sessionType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        // We need to encode the exercise type and case separately
        if let upperBody = exercise as? UpperBodyExercises {
            try container.encode("upperBody", forKey: .exercise)
            try container.encode(upperBody.rawValue, forKey: .exercise)
        } else if let lowerBody = exercise as? LowerBodyExercises {
            try container.encode("lowerBody", forKey: .exercise)
            try container.encode(lowerBody.rawValue, forKey: .exercise)
        } else if let core = exercise as? CoreExercises {
            try container.encode("core", forKey: .exercise)
            try container.encode(core.rawValue, forKey: .exercise)
        } else if let fullBody = exercise as? FullBodyExercises {
            try container.encode("fullBody", forKey: .exercise)
            try container.encode(fullBody.rawValue, forKey: .exercise)
        }
        try container.encode(sessionType, forKey: .sessionType)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let exerciseType = try container.decode(String.self, forKey: .exercise)
        let exerciseRawValue = try container.decode(String.self, forKey: .exercise)
        
        switch exerciseType {
        case "upperBody":
            exercise = UpperBodyExercises(rawValue: exerciseRawValue)!
        case "lowerBody":
            exercise = LowerBodyExercises(rawValue: exerciseRawValue)!
        case "core":
            exercise = CoreExercises(rawValue: exerciseRawValue)!
        case "fullBody":
            exercise = FullBodyExercises(rawValue: exerciseRawValue)!
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Unknown exercise type"))
        }
        
        sessionType = try container.decode(SessionType.self, forKey: .sessionType)
    }
}
