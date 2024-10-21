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
    
    public func determinePlanType(for user: UserData, userId: String) -> [Plan] {
        let bmi = calculateBMI(weight: user.weight, height: user.height)
        var plans: [Plan] = []
        
        for day in user.availibility {
            var plan = createPlan(userId: userId, bmiCategory: bmi.category, for: day, activityLevel: user.activityLevel)
            plan.weekDay = day.weekDay
            plans.append(plan)
        }
        
        return plans
    }
}

//// MARK: - Private Methods
private extension PlanMakerService {
    func calculateBMI(weight: Double, height: Double) -> BMI {
        let heightInMeters = height / 100.0
        let bmiValue = weight / (heightInMeters * heightInMeters)
        let category = BMICategory.categorize(bmi: bmiValue)
        return BMI(value: bmiValue, category: category)
    }
    
    func createPlan(userId: String,bmiCategory: BMICategory, for day: Availability, activityLevel: ActivityLevel) -> Plan {
        var plan = Plan(userId: userId, weekDay: day.weekDay, exercises: [])
        var remainingTime = day.freeTime * 60.0 * 60.0 // Convert hours to seconds
        var overalSecond: Double = 0.0
        // Extra rest time for overweight and obese categories (in seconds)
        let extraRestTime: Int = {
            switch bmiCategory {
            case .overweight:
                return 10  // Additional 30 seconds rest
            case .obese:
                return 20  // Additional 45 seconds rest
            default:
                return 0
            }
        }()
        
        switch bmiCategory {
        case .underweight:
            // Focus on strength building exercises matching activity level
            while remainingTime > 0 {
                let exercise: Exercise = {
                    switch activityLevel {
                    case .sedentary, .light:
                        return plan.exercises.count % 2 == 0 ?
                            UpperBodyExercises.tricepDips :
                            LowerBodyExercises.gluteBridge
                    case .moderate, .active:
                        return plan.exercises.count % 2 == 0 ?
                            UpperBodyExercises.pushUps :
                            LowerBodyExercises.squats
                    }
                }()
                
                let session = ExerciseSession(
                    exercise: exercise,
                    sessionType: activityLevel.duration
                )
                
                overalSecond += Double((session.sessionType.sets *
                                        (session.sessionType.rest + session.sessionType.reps)) + 10)
                plan.exercises.append(session)
                remainingTime -= Double((session.sessionType.sets *
                                         (session.sessionType.rest + session.sessionType.reps)) + 10)
            }
            
        case .normal:
            // Balanced workout with exercise intensity matching activity level
            while remainingTime > 0 {
                let exercise: Exercise = {
                    switch (plan.exercises.count % 4, activityLevel) {
                    case (0, .sedentary), (0, .light):
                        return UpperBodyExercises.tricepDips
                    case (0, _):
                        return UpperBodyExercises.pushUps
                    case (1, .sedentary), (1, .light):
                        return LowerBodyExercises.gluteBridge
                    case (1, _):
                        return LowerBodyExercises.squats
                    case (2, .sedentary):
                        return CoreExercises.sitUps
                    case (2, _):
                        return CoreExercises.plank
                    case (_, .sedentary), (_, .light):
                        return FullBodyExercises.jumpingJacks
                    default:
                        return FullBodyExercises.burpees
                    }
                }()
                
                let session = ExerciseSession(
                    exercise: exercise,
                    sessionType: activityLevel.duration
                )
                
                overalSecond += Double((session.sessionType.sets *
                                        (session.sessionType.rest + session.sessionType.reps)) + 10)
                plan.exercises.append(session)
                remainingTime -= Double((session.sessionType.sets *
                                         (session.sessionType.rest + session.sessionType.reps)) + 10)
            }
            
        case .overweight:
            // Cardio focused with intensity based on activity level and extra rest
            while remainingTime > 0 {
                let exercise: Exercise = {
                    switch (plan.exercises.count % 3, activityLevel) {
                    case (0, .sedentary), (0, .light):
                        return FullBodyExercises.jumpingJacks
                    case (0, _):
                        return FullBodyExercises.mountainClimbers
                    case (1, .sedentary):
                        return CoreExercises.sitUps
                    case (1, _):
                        return CoreExercises.bicycleCrunches
                    case (_, .sedentary), (_, .light):
                        return LowerBodyExercises.wallSit
                    default:
                        return LowerBodyExercises.lunges
                    }
                }()
                
                let baseDuration = activityLevel.duration
                let sessionType = SessionType.repsAndSets(
                    reps: baseDuration.reps,
                    sets: baseDuration.sets,
                    rest: baseDuration.rest + extraRestTime
                )
                
                let session = ExerciseSession(
                    exercise: exercise,
                    sessionType: sessionType
                )
                
                overalSecond += Double((session.sessionType.sets *
                                        (session.sessionType.rest + session.sessionType.reps)) + 10)
                plan.exercises.append(session)
                remainingTime -= Double((session.sessionType.sets *
                                         (session.sessionType.rest + session.sessionType.reps)) + 10)
            }
            
        case .obese:
            // Low impact exercises adjusted for activity level with extended rest
            while remainingTime > 0 {
                let exercise: Exercise = {
                    switch (plan.exercises.count % 3, activityLevel) {
                    case (0, .sedentary):
                        return LowerBodyExercises.wallSit
                    case (0, .light):
                        return LowerBodyExercises.gluteBridge
                    case (0, _):
                        return LowerBodyExercises.squats
                    case (1, .sedentary), (1, .light):
                        return CoreExercises.sitUps
                    case (1, _):
                        return CoreExercises.plank
                    case (_, .sedentary):
                        return FullBodyExercises.jumpingJacks
                    case (_, .light):
                        return FullBodyExercises.highKnees
                    default:
                        return FullBodyExercises.mountainClimbers
                    }
                }()
                
                let baseDuration = activityLevel.duration
                let sessionType = SessionType.repsAndSets(
                    reps: baseDuration.reps,
                    sets: baseDuration.sets,
                    rest: baseDuration.rest + extraRestTime
                )
                
                let session = ExerciseSession(
                    exercise: exercise,
                    sessionType: sessionType
                )
                
                overalSecond += Double((session.sessionType.sets *
                                        (session.sessionType.rest + session.sessionType.reps)) + 10)
                plan.exercises.append(session)
                remainingTime -= Double((session.sessionType.sets *
                                         (session.sessionType.rest + session.sessionType.reps)) + 10)
            }
        }
        return plan
    }
}
