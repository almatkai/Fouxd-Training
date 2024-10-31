//
//  EditPlanView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 20.10.2024.
//

import SwiftUI

struct EditPlanView: View {
    @EnvironmentObject private var planVM: PlanViewModel
    @EnvironmentObject private var userDataVM: UserDataViewModel
    @EnvironmentObject private var userSessionViewModel: UserSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<planVM.plans.count, id: \.self) { i in
                    let plan = planVM.plans[i]
                    let availability = userDataVM.userData.availibility[i]
                    
                    PlanCard(plan: plan, availability: availability)
                }
            }
            .padding()
        }
        .navigationTitle("Exercise plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    planVM.createPlans(userData: userDataVM.userData)
                    
                    Task {
                        await planVM.savePlans(userSession: userSessionViewModel.userSession)
                    }
                }){
                    Label("Reshuffle", systemImage: "arrow.clockwise")
                }
            }
        }
    }
}

struct PlanCard: View {
    let plan: Plan
    let availability: Availability
    
    var formattedTime: String {
        let hours = Int(availability.freeTime)
        let minutes = Int((availability.freeTime.truncatingRemainder(dividingBy: 1) * 60).rounded())
        
        if minutes == 0 {
            return hours == 1 ? "1 hour" : "\(hours) hours"
        } else if hours == 0 {
            return "\(minutes) min"
        } else {
            let hourText = hours == 1 ? "hour" : "hours"
            return "\(hours) \(hourText) \(minutes) min"
        }
    }
    
    @State var showExercises = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(plan.weekDay.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text(availability.freeTime == 0 ? "Not set" : formattedTime)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.cGradientBlue1), Color(.cGradientBlue2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.8)
            )
            .onTapGesture {
                // Slide animation like in List
                withAnimation(.easeInOut(duration: 0.3)){
                    showExercises.toggle()
                }
            }
            
            // Exercises List
            if showExercises {
                VStack(spacing: 0) {
                    ForEach(plan.exercises, id: \.self) { exercise in
                        ExerciseRow(title: exercise.exerciseWrapper.exercise.title, description: exercise.exerciseWrapper.exercise.description)
                    }
                }
                .transition(.slide.animation(.easeInOut(duration: 0.3)))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ExerciseRow: View {
    let title: String
    let description: String
    @State var showDesc = false
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: showDesc ? "chevron.down" : "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            if showDesc {
                Text(description)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Color(.cwhite)
                .overlay(
                    Color.gray.opacity(0.1)
                        .opacity(0)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)){
                showDesc.toggle()
            }
        }
        .overlay(
            Divider()
                .opacity(0.5),
            alignment: .bottom
        )
    }
}
