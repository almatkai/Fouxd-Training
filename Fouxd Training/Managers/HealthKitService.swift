//
//  HealthKitService.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 19.10.2024.
//

import Foundation
import HealthKit

// HealthKit Manager with comprehensive metrics
class HealthKitManager: ObservableObject {
    private var healthStore = HKHealthStore()
    
    // Published properties for real-time updates
    @Published var steps: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var weeklySteps: [(date: Date, steps: Double)] = []
    @Published var weeklyActivity: [(date: Date, calories: Double)] = []
    @Published var heartRate: Double = 0
    @Published var restingHeartRate: Double = 0
    @Published var vo2Max: Double = 0
    @Published var workoutMinutes: Double = 0
    @Published var waterIntake: Double = 0
    @Published var sleepHours: Double = 0
    
    // Weekly trends
    @Published var weeklyHeartRate: [(date: Date, value: Double)] = []
    @Published var weeklyWorkoutMinutes: [(date: Date, minutes: Double)] = []
    
    func requestAuthorization() {
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryWater)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchHealthData()
                }
            } else if let error = error {
                print("HealthKit authorization error: \(error)")
            }
        }
    }
    
    func fetchHealthData() {
        fetchSteps()
        fetchActiveEnergy()
        fetchWeeklyData()
        fetchHeartRateData()
        fetchVO2Max()
        fetchWorkoutMinutes()
        fetchWaterIntake()
        fetchSleepData()
    }
    
    private func fetchSteps() {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            DispatchQueue.main.async {
                self?.steps = sum.doubleValue(for: HKUnit.count())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchActiveEnergy() {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: energyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            DispatchQueue.main.async {
                self?.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWeeklyData() {
        let calendar = Calendar.current
        let now = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return }
        
        fetchWeeklyMetric(
            type: .stepCount,
            unit: .count(),
            startDate: sevenDaysAgo
        ) { [weak self] results in
            DispatchQueue.main.async {
                // Map the results to match the expected type
                self?.weeklySteps = results.map { (date: $0.date, steps: $0.value) }
            }
        }
        
        fetchWeeklyMetric(
            type: .activeEnergyBurned,
            unit: .kilocalorie(),
            startDate: sevenDaysAgo
        ) { [weak self] results in
            DispatchQueue.main.async {
                self?.weeklyActivity = results.map { (date: $0.date, calories: $0.value) }
            }
        }
    }
    
    private func fetchHeartRateData() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { [weak self] _, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                return
            }
            
            DispatchQueue.main.async {
                self?.heartRate = average.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchVO2Max() {
        let vo2Type = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        let now = Date()
        guard let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) else { return }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: thirtyDaysAgo,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: vo2Type,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { [weak self] _, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                return
            }
            
            DispatchQueue.main.async {
                self?.vo2Max = average.doubleValue(for: HKUnit(from: "ml/kg*min"))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWorkoutMinutes() {
        let workoutType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: workoutType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            DispatchQueue.main.async {
                self?.workoutMinutes = sum.doubleValue(for: HKUnit.minute())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWaterIntake() {
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: waterType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            DispatchQueue.main.async {
                self?.waterIntake = sum.doubleValue(for: HKUnit.literUnit(with: .milli))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSleepData() {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] _, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
//                print("Failed to fetch sleep data: \(error?.localizedDescription ?? "")")
                return
            }
            
            let totalSeconds = samples.reduce(0.0) { sum, sample in
                sum + sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            DispatchQueue.main.async {
                self?.sleepHours = totalSeconds / 3600 // Convert seconds to hours
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWeeklyMetric(
        type: HKQuantityTypeIdentifier,
        unit: HKUnit,
        startDate: Date,
        completion: @escaping ([(date: Date, value: Double)]) -> Void
    ) {
        let quantityType = HKQuantityType.quantityType(forIdentifier: type)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: .strictStartDate
        )
        
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                return
            }
            
            var data: [(date: Date, value: Double)] = []
            
            results.enumerateStatistics(from: startDate, to: Date()) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    data.append((date: statistics.startDate, value: sum.doubleValue(for: unit)))
                }
            }
            
            completion(data)
        }
        
        healthStore.execute(query)
    }
}
