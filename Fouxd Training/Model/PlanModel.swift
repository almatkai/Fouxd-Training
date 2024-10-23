//
//  PlanModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation
import FirebaseFirestore

// MARK: - Core Models
struct WeeklyTrainingPlan: Codable {
    let plans: [Plan]
}

struct Plan: Identifiable, Codable {
    let id: Int
    let weekDay: WeekDay
    var exercises: [ExerciseSession]
    let lastUpdated: Date
}

struct ExerciseSession: Codable, Hashable {
    let exerciseWrapper: ExerciseWrapper
    let configuration: ExerciseConfiguration
}

struct ExerciseConfiguration: Codable, Equatable, Hashable {
    let reps: Int
    let sets: Int
    let restSeconds: Int
}

enum ActivityLevel: String, Codable {
    case sedentary, light, moderate, active
    
    var displayName: String { rawValue.capitalized }
    
    var baseReps: Int {
        switch self {
        case .sedentary: return 30
        case .light: return 60
        case .moderate: return 90
        case .active: return 90
        }
    }
    
    var sets: Int {
        switch self {
        case .light: return 2
        case .sedentary, .moderate: return 3
        case .active: return 4
        }
    }
}

// MARK: - Exercise Protocol and Wrapper
// We need a wrapper enum to make the Exercise protocol Codable
enum ExerciseWrapper: Codable, Equatable, Hashable {
    case upperBody(UpperBodyExercise)
    case lowerBody(LowerBodyExercise)
    case core(CoreExercise)
    case fullBody(FullBodyExercise)
    
    var exercise: Exercise {
        switch self {
        case .upperBody(let exercise): return exercise
        case .lowerBody(let exercise): return exercise
        case .core(let exercise): return exercise
        case .fullBody(let exercise): return exercise
        }
    }
    
    static func wrap(_ exercise: any Exercise) -> ExerciseWrapper {
        switch exercise {
        case let upperBody as UpperBodyExercise:
            return .upperBody(upperBody)
        case let lowerBody as LowerBodyExercise:
            return .lowerBody(lowerBody)
        case let core as CoreExercise:
            return .core(core)
        case let fullBody as FullBodyExercise:
            return .fullBody(fullBody)
        default:
            fatalError("Unsupported exercise type: \(type(of: exercise))")
        }
    }
}

// Protocol can't be Codable directly, but conforming types will be
protocol Exercise {
    var title: String { get }
    var description: String { get }
}

// MARK: - Exercise Categories
enum ExerciseCategory: String, CaseIterable, Codable {
    case upperBody, lowerBody, core, fullBody
    
    var exercises: [Exercise] {
        switch self {
        case .upperBody: return UpperBodyExercise.allCases
        case .lowerBody: return LowerBodyExercise.allCases
        case .core: return CoreExercise.allCases
        case .fullBody: return FullBodyExercise.allCases
        }
    }
}

// MARK: - Exercise Types
enum UpperBodyExercise: String, Exercise, CaseIterable, Codable {
    case pushUps, tricepDips
    case diamondPushUps, pikePushUps, inclinePushUps
    case declinePushUps, wallPushUps
    
    var title: String { rawValue.capitalized }
    var description: String {
        switch self {
        case .pushUps: return "Classic push-ups targeting chest, shoulders, and triceps"
        case .tricepDips: return "Tricep dips targeting arm strength"
        case .diamondPushUps: return "Push-ups with hands forming diamond shape for triceps focus"
        case .pikePushUps: return "Push-ups in pike position targeting shoulders"
        case .inclinePushUps: return "Push-ups with hands elevated for beginners"
        case .declinePushUps: return "Push-ups with feet elevated for advanced chest workout"
        case .wallPushUps: return "Push-ups against wall for beginners or warm-up"
        }
    }
}

enum LowerBodyExercise: String, Exercise, CaseIterable, Codable {
    case squats, lunges, wallSit, gluteBridge
    case jumpSquats, bulgarianSplitSquat, calfRaises
    case pistolSquats, stepUps
    
    var title: String { rawValue.capitalized }
    var description: String {
        switch self {
        case .squats: return "Basic squats for leg strength"
        case .lunges: return "Forward lunges targeting legs and balance"
        case .wallSit: return "Static wall sit for endurance"
        case .gluteBridge: return "Glute bridge for lower back and hip strength"
        case .jumpSquats: return "Explosive squat jumps for power and cardio"
        case .bulgarianSplitSquat: return "Single-leg squats with rear foot elevated"
        case .calfRaises: return "Standing calf raises for lower leg strength"
        case .pistolSquats: return "Single-leg squats for advanced strength and balance"
        case .stepUps: return "Step-ups onto elevated platform for leg power"
        }
    }
}

enum CoreExercise: String, Exercise, CaseIterable, Codable {
    case plank, sitUps, legRaises, bicycleCrunches
    case sidePlank, russianTwist, mountainClimbers
    case deadBug, hollowHold
    
    var title: String { rawValue.capitalized }
    var description: String {
        switch self {
        case .plank: return "Static plank hold for core stability"
        case .sitUps: return "Basic sit-ups targeting abdominal muscles"
        case .legRaises: return "Lying leg raises for lower abs"
        case .bicycleCrunches: return "Bicycle crunches for obliques and core"
        case .sidePlank: return "Side plank for obliques and lateral core stability"
        case .russianTwist: return "Seated twists for rotational core strength"
        case .mountainClimbers: return "Dynamic plank with alternating knee drives"
        case .deadBug: return "Coordinated arm and leg movements for core control"
        case .hollowHold: return "Static hollow body hold for advanced core strength"
        }
    }
}

enum FullBodyExercise: String, Exercise, CaseIterable, Codable {
    case burpees, mountainClimbers, jumpingJacks, highKnees
    case bearCrawl, inchworm, turkishGetUp
    case manMakers, thruster
    
    var title: String { rawValue.capitalized }
    var description: String {
        switch self {
        case .burpees: return "Full body burpees for cardio and strength"
        case .mountainClimbers: return "Mountain climbers for cardio and core"
        case .jumpingJacks: return "Classic jumping jacks for cardio"
        case .highKnees: return "High knees running in place"
        case .bearCrawl: return "Quadrupedal movement pattern for full body coordination"
        case .inchworm: return "Walking hands out to plank and back for mobility"
        case .turkishGetUp: return "Complex movement from floor to standing position"
        case .manMakers: return "Combination of push-up, row, and squat thrust"
        case .thruster: return "Squat to overhead press movement pattern"
        }
    }
}
