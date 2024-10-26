//
//  HealthKitService.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 19.10.2024.
//

import Foundation
import HealthKit
import WidgetKit

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    var healthStore = HKHealthStore()
    
    @Published var stepCountToday: Int = 0
    @Published var thisWeekSteps: [Int: Int] = [1: 0, 2: 0, 3: 0,
                                               4: 0, 5: 0, 6: 0, 7: 0]
    
    // The types of data we want to read from HealthKit
    let readTypes = Set([
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        // Add other types you need here
    ])
    
    // Request authorization from the user
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // First check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(success)
        }
    }
    
    // Call this when your app starts
    func setup() {
        requestAuthorization { success in
            if success {
                // Authorization succeeded, now you can start fetching data
                print("HealthKit authorization successful")
                // Call your methods to fetch data here
                self.fetchStepCount()
            } else {
                print("HealthKit authorization failed")
            }
        }
    }
    
    // Example method to fetch step count
    private func fetchStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch steps: \(error?.localizedDescription ?? "")")
                return
            }
            
            DispatchQueue.main.async {
                self.stepCountToday = Int(sum.doubleValue(for: .count()))
            }
        }
        
        healthStore.execute(query)
    }
}
