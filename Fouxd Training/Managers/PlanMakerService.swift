//
//  PlanMakerService.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

class PlanMakerService {
    
    static let shared = PlanMakerService()
    private init() {}
    
    func createPlan(userData: UserData) -> [Plan] {
        var plans: [Plan] = []
        let availability = userData.availibility
        let activityLevel = userData.activityLevel
        let bmiCategory = BMICategory.categorize(weight: userData.weight, height: userData.height)
        var id = 1
        for day in availability {
            var plan = Plan(id: id, weekDay: day.weekDay, exercises: [], lastUpdated: Date())
            var remainingTime = Int(day.freeTime * 60 * 60) // Convert hours to seconds
            
            let extraRestTime: Int = {
                switch bmiCategory {
                case .overweight: return 10
                case .obese: return 20
                default: return 0
                }
            }()
            
            while remainingTime > 0 {
                let exercise = exerciseRandomizer(bmi: bmiCategory)
                let exerciseWrapper: ExerciseWrapper = ExerciseWrapper.wrap(exercise)
                let exerciseSession = ExerciseSession(
                    exerciseWrapper: exerciseWrapper,
                    configuration: standardConfiguration(for: activityLevel, gender: userData.gender))
                
                remainingTime -= exerciseSession.configuration.sets *
                                         (exerciseSession.configuration.restSeconds +
                                          exerciseSession.configuration.reps) + extraRestTime
                
                plan.exercises.append(exerciseSession)
            }
            if !plan.exercises.isEmpty {
                plan.exercises.removeLast()
            }
            
            plans.append(plan)
            id += 1
        }
        
        return plans
    }
    
    private func standardConfiguration(for level: ActivityLevel, gender: Gender) -> ExerciseConfiguration {
        let reps = gender == .female ?
            (level.baseReps > 60 ? level.baseReps - 20 : level.baseReps - 10) : level.baseReps
        
        return ExerciseConfiguration(
            reps: reps,
            sets: level.sets,
            restSeconds: 30
        )
    }
    
    private var categoryWeights: [ExerciseCategory: Int] = [
        .core: 1,
        .fullBody: 1,
        .lowerBody: 1,
        .upperBody: 1
    ]

    func exerciseRandomizer(bmi: BMICategory) -> Exercise {

        switch bmi {
        case .underweight:
            categoryWeights[.fullBody] = 3
            categoryWeights[.core] = 2
            categoryWeights[.lowerBody] = 1
            categoryWeights[.upperBody] = 1
        case .normal:
            categoryWeights[.fullBody] = 2
            categoryWeights[.core] = 2
            categoryWeights[.lowerBody] = 2
            categoryWeights[.upperBody] = 2
        case .overweight:
            categoryWeights[.lowerBody] = 3
            categoryWeights[.core] = 2
            categoryWeights[.upperBody] = 1
            categoryWeights[.fullBody] = 1
        case .obese:
            categoryWeights[.lowerBody] = 4
            categoryWeights[.core] = 3
            categoryWeights[.fullBody] = 1
            categoryWeights[.upperBody] = 1
        }

        // Get all categories with their weights
        let categories = ExerciseCategory.allCases
        var weightedCategories: [ExerciseCategory] = []
        
        // Populate the weighted list of categories
        for category in categories {
            if let weight = categoryWeights[category] {
                for _ in 0..<weight {
                    weightedCategories.append(category)
                }
            }
        }
        
        // Randomly select a category from the weighted list
        guard let selectedCategory = weightedCategories.randomElement() else {
            fatalError("No exercise category found")
        }

        // Fetch a random exercise from the selected category
        return getRandomExercise(for: selectedCategory)
    }

    // Assume this function returns a random Exercise for the given category
    func getRandomExercise(for category: ExerciseCategory) -> Exercise {
        // Fetch the list of exercises for the given category
        let exercises = category.exercises
        
        // Randomly select an exercise from the list
        guard let randomExercise = exercises.randomElement() else {
            fatalError("No exercises available for the selected category")
        }
        
        return randomExercise
    }
}
