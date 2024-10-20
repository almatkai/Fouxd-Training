//
//  PlanModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

struct Plan {
    var weekDay: WeekDay
    var exercises: [ExerciseSession]
}

enum SessionType {
    case repsAndSets(reps: Int, sets: Int, rest: Int) // reps in seconds
}

struct ExerciseSession {
    var exercise: Exercise
    var sessionType: SessionType
}

protocol Exercise {
    var activityLevel: ActivityLevel { get }
}

enum UpperBodyExercises: Exercise {
    case pushUps
    case tricepDips
    
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

enum LowerBodyExercises: Exercise {
    case squats
    case lunges
    case wallSit
    case gluteBridge
    
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

enum CoreExercises: Exercise {
    case plank
    case sitUps
    case legRaises
    case bicycleCrunches
    
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

enum FullBodyExercises: Exercise {
    case burpees
    case mountainClimbers
    case jumpingJacks
    case highKnees
    
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

//var title: String {
//    switch self {
//    case .pushUps:
//        return "Push Ups"
//    case .squats:
//        return "Squats"
//    case .sitUps:
//        return "Sit Ups"
//    case .plank:
//        return "Plank"
//    case .burpees:
//        return "Burpees"
//    case .lunges:
//        return "Lunges"
//    case .jumpingJacks:
//        return "Jumping Jacks"
//    case .mountainClimbers:
//        return "Mountain Climbers"
//    case .highKnees:
//        return "High Knees"
//    case .tricepDips:
//        return "Tricep Dips"
//    case .legRaises:
//        return "Leg Raises"
//    case .bicycleCrunches:
//        return "Bicycle Crunches"
//    case .wallSit:
//        return "Wall Sit"
//    case .gluteBridge:
//        return "Glute Bridge"
//    }
//}

//var description: String {
//    switch self {
//    case .pushUps:
//        return "Push-ups are a great upper body exercise that target the chest, shoulders, and triceps."
//    case .squats:
//        return "Squats are a great lower body exercise that target the quads, hamstrings, and glutes."
//    case .sitUps:
//        return "Sit-ups are a great core exercise that target the abs and obliques."
//    case .plank:
//        return "Planks are a great core exercise that target the abs, obliques, and lower back."
//    case .burpees:
//        return "Burpees are a full body exercise that target the chest, shoulders, triceps, quads, hamstrings, and glutes."
//    case .lunges:
//        return "Lunges are a great lower body exercise that target the quads, hamstrings, and glutes."
//    case .jumpingJacks:
//        return "Jumping jacks are a great full body exercise that target the heart, legs, and arms."
//    case .mountainClimbers:
//        return "Mountain climbers are a great full body exercise that target the abs, shoulders, and legs."
//    case .highKnees:
//        return "High knees are a great cardio exercise that target the heart and legs."
//    case .tricepDips:
//        return "Tricep dips are a great upper body exercise that target the triceps and shoulders."
//    case .legRaises:
//        return "Leg raises are a great core exercise that target the lower abs."
//    case .bicycleCrunches:
//        return "Bicycle crunches are a great core exercise that target the abs and obliques."
//    case .wallSit:
//        return "Wall sits are a great lower body exercise that target the quads and hamstrings."
//    case .gluteBridge:
//        return "Glute bridges are a great lower body exercise that target the glutes and hamstrings."
//    }
//}
