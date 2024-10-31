//
//  WorkoutSessionView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import SwiftUI
import Combine

enum WorkoutState {
    case preparing
    case exercising
    case resting
    case completed
}

// MARK: - Workout Session View
struct WorkoutSessionView: View {
    let exercises: [ExerciseSession]
    let onComplete: (WorkoutHistory) -> Void
    
    @StateObject private var viewModel: WorkoutSessionViewModel
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmation = false
    
    init(exercises: [ExerciseSession], onComplete: @escaping (WorkoutHistory) -> Void) {
        self.exercises = exercises
        self.onComplete = onComplete
        self._viewModel = StateObject(wrappedValue: WorkoutSessionViewModel(exercises: exercises))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    switch viewModel.currentState {
                    case .preparing:
                        preparationView
                    case .exercising:
                        exerciseView
                    case .resting:
                        restingView
                    case .completed:
                        completionView
                    }
                }
            }
            
            .navigationTitle("Workout Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentState != .completed {
                        Button(viewModel.isPaused ? "Resume" : "Pause") {
                            viewModel.togglePause()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentState != .completed {
                        Button("End") {
                            showingConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .confirmationDialog(
                "End Workout?",
                isPresented: $showingConfirmation
            ) {
                Button("End Workout", role: .destructive) {
                    completeWorkout(isFinished: false)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to end this workout? Your progress will be saved.")
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .inactive, .background:
                    viewModel.isPaused = true
                    viewModel.timer?.cancel()
                case .active:
                    if !viewModel.isPaused {
                        viewModel.resume()
                    }
                @unknown default:
                    break
                }
            }
        }
        .tint(Color("cTintColor"))
    }
    
    private var preparationView: some View {
        VStack(spacing: 20) {
            Text("Get Ready!")
                .font(.title)
                .fontWeight(.bold)
            
            CircularTimerView(
                progress: viewModel.progress,
                remainingSeconds: viewModel.timeRemaining,
                totalSeconds: 5
            )
            
            Text("Prepare for: \(viewModel.currentExercise?.exerciseWrapper.exercise.title ?? "")")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            GifImageView(viewModel.currentExercise?.exerciseWrapper.exercise.gifName ?? "rollOver")
        }
        .onAppear {
            viewModel.startWorkout()
        }
    }
    
    private var exerciseView: some View {
        VStack(spacing: 20) {
            Text(viewModel.currentExercise?.exerciseWrapper.exercise.title ?? "")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Set \(viewModel.currentSetCount + 1) of \(viewModel.currentExercise?.configuration.sets ?? 0)")
                .font(.headline)
            
            CircularTimerView(
                progress: viewModel.progress,
                remainingSeconds: viewModel.timeRemaining,
                totalSeconds: viewModel.currentExercise?.configuration.reps ?? 0
            )
            
            GifImageView(viewModel.currentExercise?.exerciseWrapper.exercise.gifName ?? "rollOver")
        }
    }
    private var restingView: some View {
        VStack(spacing: 20) {
            Text("Rest")
                .font(.title)
                .fontWeight(.bold)
            
            CircularTimerView(
                progress: viewModel.progress,
                remainingSeconds: viewModel.timeRemaining,
                totalSeconds: viewModel.currentExercise?.configuration.restSeconds ?? 0
            )
            
            Text("Prepare for: \(viewModel.currentExercise?.exerciseWrapper.exercise.title ?? "Missing")")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            GifImageView(viewModel.currentExercise?.exerciseWrapper.exercise.gifName ?? "rollOver")
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Workout Complete!")
                .font(.title)
            
            if let startTime = viewModel.startTime {
                Text("Duration: \(formatDuration(from: startTime))")
                    .font(.headline)
            }
            
            Text("Completed \(viewModel.completedExercises.count) exercises")
                .font(.subheadline)
            
            Button("Finish") {
                completeWorkout(isFinished: true)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var nextExercise: Exercise {
        guard viewModel.currentExerciseIndex + 1 < exercises.count else { return exercises[0].exerciseWrapper.exercise }
        return exercises[viewModel.currentExerciseIndex + 1].exerciseWrapper.exercise
    }
    
    private func formatDuration(from start: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: start, to: Date()) ?? "N/A"
    }
    
    private func completeWorkout(isFinished: Bool) {
        guard let startTime = viewModel.startTime else { return }
        let endTime = Date()
        
        let history = WorkoutHistory(
            user_id: userSessionVM.userSession?.uid,
            date: startTime,
            duration: endTime.timeIntervalSince(startTime),
            exercisesCompleted: viewModel.completedExercises.count,
            totalExercises: exercises.count,
            isCompleted: isFinished
        )
        
        onComplete(history)
    }
}
