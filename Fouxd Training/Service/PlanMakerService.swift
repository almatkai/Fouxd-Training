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
    
    public func determinePlanType(for user: UserData) -> [Plan] {
        let bmi = calculateBMI(weight: user.weight, height: user.height)
        var plans: [Plan] = []
        
        for day in user.availibility {
            let freeTimeCategory = categorizeFreeTime(hoursPerDay: day.freeTime)
            var plan = createPlan(bmiCategory: bmi.category, freeTimeCategory: freeTimeCategory, goal: user.goal, day: day.weekDay)
            plan.weekDay = day.weekDay
            plans.append(plan)
        }
        
        return plans
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
    
    private func categorizeFreeTime(hoursPerDay: Double) -> FreeTimeCategory {
        switch hoursPerDay {
        case 3...:
            return .highAvailability
        case 2..<3:
            return .moderateHighAvailability
        case 1..<2:
            return .moderateLowAvailability
        case 0.5..<1:
            return .lowHighAvailability
        case 0.25..<0.5:
            return .lowLowAvailability
        case 0..<0.25:
            return .veryMinimal
        default:
            return .veryMinimal 
        }
    }
    
    private func createPlan(bmiCategory: BMICategory, freeTimeCategory: FreeTimeCategory, goal: FitnessGoal, day: WeekDay) -> Plan {
        // Customize the Plan based on the three factors
        switch (bmiCategory, freeTimeCategory, goal) {
        case (.underweight, .highAvailability, .muscleGain):
            return createMuscleGainPlan(highIntensity: true, day: day)
        case (.underweight, _, .muscleGain):
            return createMuscleGainPlan(highIntensity: false, day: day)
            
        case (.normal, .highAvailability, .endurance):
            return createEndurancePlan(highIntensity: true, day: day)
        case (.normal, _, .endurance):
            return createEndurancePlan(highIntensity: false, day: day)
            
        case (.overweight, .highAvailability, .weightLoss), (.obese, .highAvailability, .weightLoss):
            return createWeightLossPlan(highIntensity: true, day: day)
        case (.overweight, _, .weightLoss), (.obese, _, .weightLoss):
            return createWeightLossPlan(highIntensity: false, day: day)
            
        default:
            return createGeneralFitnessPlan(day: day) // Default fallback plan
        }
    }
    
    // MARK: - Helper functions for creating specific plans
    private func createMuscleGainPlan(highIntensity: Bool, day: WeekDay) -> Plan {
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
            weekDay: day,
            sessionDuration: highIntensity ? 60 : 45,
            focus: "Muscle Gain",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Increase daily caloric intake by 250-500 kcal above maintenance."
        )
    }
    
    private func createEndurancePlan(highIntensity: Bool, day: WeekDay) -> Plan {
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
            weekDay: day,
            sessionDuration: highIntensity ? 60 : 45,
            focus: "Endurance",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Maintain caloric intake for endurance maintenance."
        )
    }
    
    private func createWeightLossPlan(highIntensity: Bool, day: WeekDay) -> Plan {
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
            weekDay: day,
            sessionDuration: highIntensity ? 45 : 30,
            focus: "Weight Loss",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Create a caloric deficit of 500-750 kcal from maintenance."
        )
    }
    
    private func createGeneralFitnessPlan(day: WeekDay) -> Plan {
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
            weekDay: day,
            sessionDuration: 40,
            focus: "General Fitness",
            cardio: cardio,
            strengthTraining: strength,
            caloricAdjustment: "Maintain current caloric intake."
        )
    }
}
