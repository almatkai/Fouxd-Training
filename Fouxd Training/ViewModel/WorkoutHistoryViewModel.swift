//
//  WorkoutHistoryViewModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import SwiftUI

// MARK: - Workout History View Model
class WorkoutHistoryViewModel: ObservableObject {
    @Published var workoutHistory: [WorkoutHistory] = []
    @Published var weeklyCompletion: Double = 0
    
    init() {
        calculateWeeklyCompletion()
    }
    
    func calculateWeeklyCompletion() {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let recentWorkouts = workoutHistory.filter { $0.date >= oneWeekAgo }
        let completedWorkouts = recentWorkouts.filter { $0.isCompleted }.count
        
        weeklyCompletion = (Double(completedWorkouts) / 7.0) * 100
    }
    
    func addWorkoutHistory(_ history: WorkoutHistory) {
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
        calculateWeeklyCompletion()
    }
    
    func fetchWorkoutHistory(userId: String?) {
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

// MARK: - Supporting Views
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

struct WorkoutHistoryCard: View {
    let workout: WorkoutHistory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(formatDate(workout.date))
                    .font(.headline)
                
                Text("\(workout.exercisesCompleted)/\(workout.totalExercises) exercises")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(formatDuration(workout.duration))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                
                Text("\(Int(workout.completionPercentage))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(22)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "N/A"
    }
}
