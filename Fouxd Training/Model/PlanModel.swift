//
//  PlanModel.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 15.10.2024.
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

struct ExerciseSession: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
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
        case .sedentary: return 6 // Test 7 seconds
        case .light: return 60
        case .moderate: return 80
        case .active: return 80
        }
    }
    
    var sets: Int {
        switch self {
        case .sedentary: return 1
        case .light: return 2
        case .moderate: return 3
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
    var gifName: String { get }
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
    
    case pushUps = "Push-Ups"
    case tricepDips = "Tricep Dips"
    case hinduPushUps = "Hindu Push-Ups"
    case pikePushUps = "Pike Push-Ups"
    case squatWithOverheadTricep = "Squat With Overhead Tricep"
    
    var title: String { rawValue }
    
    var description: String {
        switch self {
        case .pushUps: return "Classic push-ups targeting chest, shoulders, and triceps"
        case .tricepDips: return "Tricep dips targeting arm strength"
        case .hinduPushUps: return "Push-ups with hands forming diamond shape for triceps focus"
        case .pikePushUps: return "Push-ups in pike position targeting shoulders"
        case .squatWithOverheadTricep: return "Push-ups with feet elevated for advanced chest workout"
        }
    }
    
    var gifName: String {
        switch self {
        case .pushUps: return "push-ups"
        case .tricepDips: return "tricep-dips"
        case .hinduPushUps: return "hindu-push-ups"
        case .pikePushUps: return "pike-push-ups"
        case .squatWithOverheadTricep: return "squatWithOverheadTricep"
        }
    }
}

enum LowerBodyExercise: String, Exercise, CaseIterable, Codable {
    case highKnees = "High Knees"
    case heisman = "Heisman"
    case jumpStart = "Jump Start"
    case jumpSquats = "Jump Squats"
    case bulgarianSplitSquat = "Bulgarian Split Squat"
    case ankleHops = "Ankle Hops"
    case shrimpSquat = "Shrimp Squats"
    case singleLegSquatKickback = "Step Ups"
    
    var title: String { rawValue }
    
    var description: String {
        switch self {
        case .highKnees: return "Basic high Knees for leg strength"
        case .heisman: return "Forward lunges targeting legs and balance"
        case .jumpStart: return "Static wall sit for endurance" //
        case .jumpSquats: return "Explosive squat jumps for power and cardio"
        case .bulgarianSplitSquat: return "Single-leg squats with rear foot elevated"
        case .ankleHops: return "Standing calf raises for lower leg strength" //
        case .shrimpSquat: return "Single-leg squats for advanced strength and balance" //
        case .singleLegSquatKickback: return "Step-ups onto elevated platform for leg power" //
        }
    }
    
    var gifName: String {
        switch self {
        case .highKnees: return "highKnees" //
        case .heisman: return "heisman" //
        case .jumpStart: return "jumpStart" //
        case .jumpSquats: return "jump-squats" //
        case .bulgarianSplitSquat: return "bulgarian-split-squat" //
        case .ankleHops: return "calf-raises" //
        case .shrimpSquat: return "shrimpSquat" //
        case .singleLegSquatKickback: return "singleLegSquatKickback" //
        }
    }
}

enum CoreExercise: String, Exercise, CaseIterable, Codable {
    case plank = "Plank"
    case sitUps = "Sit-Ups"
    case reversePlankLegRaises = "Reverse Plank Leg Raises"
    case bicycleCrunches = "Bicycle Crunches"
    case sidePlankRotation = "Side Plank Rotation"
    case russianTwist = "Russian Twist"
    case mountainClimbers = "Mountain Climbers"
    case singleLegBridge = "Single Leg Bridge"
    
    var title: String { rawValue }
    
    var description: String {
        switch self {
        case .plank: return "Static plank hold for core stability"
        case .sitUps: return "Basic sit-ups targeting abdominal muscles"
        case .reversePlankLegRaises: return "Reverse Plank Leg Raises" //
        case .bicycleCrunches: return "Bicycle crunches for obliques and core"
        case .sidePlankRotation: return "Side plank with rotation for obliques and lateral core stability"
        case .russianTwist: return "Seated twists for rotational core strength"
        case .mountainClimbers: return "Dynamic plank with alternating knee drives"
        case .singleLegBridge: return "Coordinated arm and leg movements for core control"
        }
    }
    
    var gifName: String {
        switch self {
        case .plank: return "plank" //
        case .sitUps: return "bicycleCrunches"//
        case .reversePlankLegRaises: return "reversePlankLegRaises" //
        case .bicycleCrunches: return "bicycleCrunches" //
        case .sidePlankRotation: return "sidePlankRotation" //
        case .russianTwist: return "russianTwist" //
        case .mountainClimbers: return "mountainClimbers"
        case .singleLegBridge: return "singleLegBridge"//
        }
    }
}

enum FullBodyExercise: String, Exercise, CaseIterable, Codable {
    case rollOver = "Roll Over"
    case lungePunch = "Lunge Punch"
    case jumpRope = "Jump Rope"
    case inchworm = "Inchworm"
    case sideLungeToLeg = "Side Lunge To Leg"
    
    var title: String { rawValue }

    var description: String {
        switch self {
        case .rollOver: return "Lie on back, roll over to stand up for mobility"
        case .lungePunch: return "Lunges with punch for leg and core strength"
        case .jumpRope: return "Jump rope for cardio and coordination"
        case .inchworm: return "Walking hands out to plank and back for mobility"
        case .sideLungeToLeg: return "Lateral lunge with leg lift for balance and strength"
        }
    }
    
    var gifName: String {
        switch self {
        case .rollOver: return "rollOver" //
        case .lungePunch: return "lungePunch" //
        case .jumpRope: return "jumpRope" //
        case .inchworm: return "inchworm" //
        case .sideLungeToLeg: return "SideLungeToLeg" //
        }
    }
}
