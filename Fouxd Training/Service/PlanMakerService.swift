//
//  PlanMakerService.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

class PlanMakerService {
    // Singleton
    static let shared = PlanMakerService()
    
    private init() {}
    
    public func determinePlanType(for user: UserModel) -> Plan {
        // Calculate BMI
        let bmi = calculateBMI(weight: user.weight, height: user.height)
        let freeTimeCategory = categorizeFreeTime(days: user.freeDays, hoursPerDay: user.freeHour)
        
        // Determine plan based on BMI, free time category, and fitness goal
        return createPlan(bmiCategory: bmi.category, freeTimeCategory: freeTimeCategory, goal: user.goal)
    }
}

// MARK: - Enums
private extension PlanMakerService{
    enum FreeTimeCategory {
        case highAvailability
        case moderateHighAvailability
        case moderateLowAvailability
        case lowHighAvailability
        case lowLowAvailability
        case veryLowHighAvailability
        case veryLowLowAvailability
        case minimalHighAvailability
        case minimalLowAvailability
        case veryMinimal
    }
}

// MARK: - Private Methods
private extension PlanMakerService{
    private func calculateBMI(weight: Double, height: Double) -> BMI {
        let heightInMeters = height / 100.0
        let bmiValue = weight / (heightInMeters * heightInMeters)
        let category = BMICategory.categorize(bmi: bmiValue)
        return BMI(value: bmiValue, category: category)
    }
    
    private func categorizeFreeTime(days: Int, hoursPerDay: Double) -> FreeTimeCategory {
        switch (days, hoursPerDay) {
        case (5..., let h) where h >= 1:
            return .highAvailability
        case (4...5, let h) where h >= 1:
            return .moderateHighAvailability
        case (4...5, 0.5...1):
            return .moderateLowAvailability
        case (3...4, let h) where h >= 1:
            return .lowHighAvailability
        case (3...4, 0.5...1):
            return .lowLowAvailability
        case (2...3, let h) where h >= 1:
            return .veryLowHighAvailability
        case (2...3, 0.5...1):
            return .veryLowLowAvailability
        case (1...2, let h) where h >= 1:
            return .minimalHighAvailability
        case (1...2, 0.5...1):
            return .minimalLowAvailability
        default:
            return .veryMinimal
        }
    }
    
    private func createPlan(bmiCategory: BMICategory, freeTimeCategory: FreeTimeCategory, goal: FitnessGoal) -> Plan {
        // Customize the Plan based on the three factors
        switch (bmiCategory, freeTimeCategory, goal) {
        case (.underweight, .highAvailability, .muscleGain):
            return createMuscleGainPlan(highIntensity: true)
        case (.underweight, _, .muscleGain):
            return createMuscleGainPlan(highIntensity: false)
            
        case (.normal, .highAvailability, .endurance):
            return createEndurancePlan(highIntensity: true)
        case (.normal, _, .endurance):
            return createEndurancePlan(highIntensity: false)
            
        case (.overweight, .highAvailability, .weightLoss), (.obese, .highAvailability, .weightLoss):
            return createWeightLossPlan(highIntensity: true)
        case (.overweight, _, .weightLoss), (.obese, _, .weightLoss):
            return createWeightLossPlan(highIntensity: false)
            
        default:
            return createGeneralFitnessPlan() // Default fallback plan
        }
    }
    
    // Helper functions for creating specific plans
    private func createMuscleGainPlan(highIntensity: Bool) -> Plan {
        let cardio = CardioPlan(
            intensity: highIntensity ? .medium : .low,
            duration: highIntensity ? 15 : 10,
            frequency: highIntensity ? 3 : 2
        )
        
        let strength = StrengthPlan(
            focus: "Muscle Hypertrophy",
            exercises: ["Squats", "Bench Press", "Deadlifts", "Overhead Press"],
            setsAndReps: highIntensity ? "5 sets of 6-8 reps" : "3-4 sets of 8-12 reps"
        )
        
        return Plan(
            daysPerWeek: highIntensity ? 5 : 4,
            sessionDuration: highIntensity ? 60 : 45,
            focus: "Muscle Gain",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Increase daily caloric intake by 250-500 kcal above maintenance."
        )
    }
    
    private func createEndurancePlan(highIntensity: Bool) -> Plan {
        let cardio = CardioPlan(
            intensity: highIntensity ? .high : .medium,
            duration: highIntensity ? 45 : 30,
            frequency: highIntensity ? 5 : 4
        )
        
        let strength = StrengthPlan(
            focus: "Full-body Endurance",
            exercises: ["Circuit Training", "Bodyweight Squats", "Push-ups", "Burpees"],
            setsAndReps: highIntensity ? "4 sets of 15-20 reps" : "3 sets of 12-15 reps"
        )
        
        return Plan(
            daysPerWeek: highIntensity ? 6 : 5,
            sessionDuration: highIntensity ? 60 : 45,
            focus: "Endurance",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Maintain caloric intake for endurance maintenance."
        )
    }
    
    private func createWeightLossPlan(highIntensity: Bool) -> Plan {
        let cardio = CardioPlan(
            intensity: highIntensity ? .high : .medium,
            duration: highIntensity ? 30 : 20,
            frequency: highIntensity ? 5 : 3
        )
        
        let strength = StrengthPlan(
            focus: "Circuit Training",
            exercises: ["Jumping Jacks", "Mountain Climbers", "Squats", "Planks"],
            setsAndReps: highIntensity ? "3 sets of 15-20 reps" : "2 sets of 12-15 reps"
        )
        
        return Plan(
            daysPerWeek: highIntensity ? 5 : 3,
            sessionDuration: highIntensity ? 45 : 30,
            focus: "Weight Loss",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Create a caloric deficit of 500-750 kcal from maintenance."
        )
    }
    
    private func createGeneralFitnessPlan() -> Plan {
        let cardio = CardioPlan(
            intensity: .medium,
            duration: 25,
            frequency: 3
        )
        
        let strength = StrengthPlan(
            focus: "Full-body Fitness",
            exercises: ["Push-ups", "Squats", "Rows", "Planks"],
            setsAndReps: "3 sets of 12-15 reps"
        )
        
        return Plan(
            daysPerWeek: 3,
            sessionDuration: 40,
            focus: "General Fitness",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Maintain current caloric intake."
        )
    }
}
