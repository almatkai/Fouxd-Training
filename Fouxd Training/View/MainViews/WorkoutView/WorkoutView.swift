//
//  HistoryView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 17.10.2024.
//

import SwiftUI
import Combine


// MARK: - Workout View
struct WorkoutView: View {
    @EnvironmentObject private var planVM: PlanViewModel
    @EnvironmentObject private var userSessionVM: UserSessionViewModel
    @EnvironmentObject private var historyVM: WorkoutHistoryViewModel
    
    @State private var showingWorkoutSession = false
    
    var todaysExercises: [ExerciseSession] {
        let today = Calendar.current.component(.weekday, from: Date()) - 2
        let weekDay = WeekDay.allCases[today]
        
        print(today)
        print(weekDay.rawValue)
        return planVM.plans.first(where: { $0.weekDay == weekDay })?.exercises ?? []
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    weeklyProgressCard
                    
                    todaysWorkoutCard
                    
                    workoutHistorySection
                }
                .padding()
            }
            .navigationTitle("Workout")
        }
        .sheet(isPresented: $showingWorkoutSession) {
            WorkoutSessionView(
                exercises: todaysExercises,
                onComplete: { history in
                    Task {
                        historyVM.addWorkoutHistory(history, planVM.plans)
                    }
                }
            )
        }
        .onAppear {
            historyVM.calculateWeeklyCompletion(planVM.plans)
        }
    }
    
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Progress")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(.white))
            HStack {
                CircularProgressView(progress: historyVM.weeklyCompletion / 100)
                    .frame(width: 100, height: 100)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(historyVM.weeklyCompletion))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.white))
                    Text("of weekly goal")
                        .foregroundColor(Color(.white))
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background {
            Image("weekly_progress")
                .frame(maxHeight: .infinity)
                .opacity(0.7)
        }
        .cornerRadius(22)
        .shadow(radius: 5)
    }
    
    private var todaysWorkoutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Workout")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(todaysExercises.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Exercises")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    showingWorkoutSession = true
                    vibrate()
                    
                    print("Exercise",todaysExercises.count)
                    for exercise in todaysExercises {
                        print(exercise.exerciseWrapper.exercise.title)
                    }
                }) {
                    Text("Start")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color("cpink-2"))
                        .cornerRadius(22)
                }
            }
        }
        .padding()
        .background {
            Image("pink_background")
                .frame(maxHeight: .infinity)
        }
        .cornerRadius(22)
    }
    
    private var workoutHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activities")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(historyVM.workoutHistory) { workout in
                WorkoutHistoryCard(workout: workout)
            }
        }
    }
}

struct ExerciseCard: View {
    let session: ExerciseSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.exerciseWrapper.exercise.title)
                .font(.headline)
            
            Text(session.exerciseWrapper.exercise.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                Label("\(session.configuration.sets) sets", systemImage: "repeat")
                Label("\(session.configuration.reps) reps", systemImage: "figure.walk")
                Label("\(session.configuration.restSeconds)s rest", systemImage: "timer")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.cwhiteAndDarkGray))
        .cornerRadius(22)
        .shadow(radius: 2)
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
                .foregroundColor(Color(.cGradientPurple2))
            
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.cpink)
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
        .background(Color(.cwhiteAndDarkGray))
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
