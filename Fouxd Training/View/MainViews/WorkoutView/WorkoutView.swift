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
        let today = 7 - Calendar.current.component(.weekday, from: Date())
        let weekDay = WeekDay.allCases[today]
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
            .onAppear {
                historyVM.fetchWorkoutHistory(userId: userSessionVM.userSession?.uid ?? "")
            }
        }
        .sheet(isPresented: $showingWorkoutSession) {
            WorkoutSessionView(
                exercises: todaysExercises,
                onComplete: { history in
                    Task {
                        historyVM.addWorkoutHistory(history)
                    }
                }
            )
        }
    }
    
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                CircularProgressView(progress: historyVM.weeklyCompletion / 100)
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(historyVM.weeklyCompletion))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("of weekly goal")
                        .foregroundColor(.gray)
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
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
                }) {
                    Text("Start")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(22)
        .shadow(radius: 5)
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
        .background(Color(.systemBackground))
        .cornerRadius(22)
        .shadow(radius: 2)
    }
}
