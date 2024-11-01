//
//  WorkoutSessionViewModel.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import Foundation
import Combine

// MARK: - Workout Session View Model
class WorkoutSessionViewModel: ObservableObject {
    @Published var currentState: WorkoutState = .preparing
    @Published var timeRemaining: Int = 5
    @Published var currentExerciseIndex = 0
    @Published var currentSetCount = 0
    @Published var completedExercises: [CompletedExercise] = []
    @Published var isPaused: Bool = false
    
    var exercises: [ExerciseSession]
    var timer: AnyCancellable?
    var startTime: Date?
    var exerciseStartTime: Date?
    
    var progress: Double {
        switch currentState {
        case .exercising:
            return 1.0 - (Double(timeRemaining) / Double(currentExercise?.configuration.reps ?? 1))
        case .resting:
            return 1.0 - (Double(timeRemaining) / Double(currentExercise?.configuration.restSeconds ?? 1))
        case .preparing:
            return 1.0 - (Double(timeRemaining) / 5.0)
        case .completed:
            return 1.0
        }
    }
    
    var currentExercise: ExerciseSession? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    init(exercises: [ExerciseSession]) {
        self.exercises = exercises
    }
    
    func startWorkout() {
        startTime = Date()
        startPreparationTimer()
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.cancel()
        } else {
            resume()
        }
    }
    
    private func startPreparationTimer() {
        currentState = .preparing
        timeRemaining = 5
        startTimer()
    }
    
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    switch self.currentState {
                    case .preparing:
                        self.startExercise()
                    case .exercising:
                        self.completeSet()
                    case .resting:
                        self.startExercise()
                    case .completed:
                        break
                    }
                }
            }
    }
    
    private func startExercise() {
        guard currentExerciseIndex < exercises.count else {
            completeWorkout()
            return
        }
        
        currentState = .exercising
        exerciseStartTime = Date()
        timeRemaining = currentExercise?.configuration.reps ?? 0
        startTimer()
    }
    
    func completeSet() {
        guard currentExerciseIndex < exercises.count else { return }
        
        let exercise = exercises[currentExerciseIndex]
        currentSetCount += 1
        
        if currentSetCount >= exercise.configuration.sets {
            completeExercise()
        } else {
            startRestTimer()
        }
    }
    
    private func completeExercise() {
        if let startTime = exerciseStartTime {
            let completedExercise = CompletedExercise(
                id: UUID(),
                exercise: currentExercise!.exerciseWrapper,
                configuration: currentExercise!.configuration,
                completedSets: (0..<currentExercise!.configuration.sets).map { _ in
                    CompletedSet(reps: currentExercise!.configuration.reps, timestamp: Date())
                },
                startTime: startTime,
                endTime: Date()
            )
            completedExercises.append(completedExercise)
        }
        
        currentExerciseIndex += 1
        currentSetCount = 0
        
        if currentExerciseIndex < exercises.count {
            startRestTimer()
        } else {
            completeWorkout()
        }
    }
    
    private func startRestTimer() {
        currentState = .resting
        timeRemaining = currentExercise?.configuration.restSeconds ?? 0
        startTimer()
    }
    
    private func completeWorkout() {
        timer?.cancel()
        currentState = .completed
    }
    
    func resume() {
        switch currentState {
        case .preparing:
            startPreparationTimer()
        case .exercising:
            startTimer()
        case .resting:
            startTimer()
        case .completed:
            break
        }
    }
    
    deinit {
        timer?.cancel()
    }
}
