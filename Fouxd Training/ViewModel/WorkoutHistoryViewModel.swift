//
//  WorkoutHistoryViewModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import SwiftUI
import Combine

// MARK: - Workout History View Model
class WorkoutHistoryViewModel: ObservableObject {
    @Published var workoutHistory: [WorkoutHistory] = []
    @Published var weeklyCompletion: Double = 0

    private var cancellables = Set<AnyCancellable>()
    private let plansPublisher: AnyPublisher<[Plan], Never>
    
    init(plansPublisher: AnyPublisher<[Plan], Never>) {
        self.plansPublisher = plansPublisher
        $workoutHistory
            .combineLatest(plansPublisher)
            .sink { [weak self] workoutHistory, plans in
                self?.calculateWeeklyCompletion(plans)
            }
            .store(in: &cancellables)
    }
    
    func calculateWeeklyCompletion(_ plans: [Plan]) {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekWorkouts = workoutHistory.filter { workout in
            calendar.isDate(workout.date, equalTo: today, toGranularity: .weekOfYear) &&
            calendar.isDate(workout.date, equalTo: today, toGranularity: .year)
        }
        
        let totalCompleted = currentWeekWorkouts.reduce(0) { $0 + $1.exercisesCompleted }
        let totalPlanned = plans.reduce(0) { $0 + $1.exercises.count }
        
        weeklyCompletion = totalPlanned > 0 ? min((Double(totalCompleted) / Double(totalPlanned)) * 100, 100) : 0
    }
    
    func addWorkoutHistory(_ history: WorkoutHistory, _ plans: [Plan]) {
        workoutHistory.insert(history, at: 0)
        if let userId = history.user_id {
            FBMWorkoutHistory.shared.create(history: history) { _ in }
        } else {
            do {
                try UDWorkoutHistory.shared.create(history: history)
            } catch {
                print("Failed to add workout history UD: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchWorkoutHistory(userId: String?, _ plans: [Plan]) {
        if let userId = userId {
            FBMWorkoutHistory.shared.readAll(userId: userId) { result in
                switch result {
                case .success(let workoutHistory):
                    DispatchQueue.main.async { [weak self] in
                        self?.workoutHistory = workoutHistory
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Failed to fetch workout history FBM: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            let workoutHistory = UDWorkoutHistory.shared.readAll()
            DispatchQueue.main.async { [weak self] in
                self?.workoutHistory = workoutHistory
            }
        }
    }
}
