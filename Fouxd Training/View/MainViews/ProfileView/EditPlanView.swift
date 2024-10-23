//
//  EditPlanView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 20.10.2024.
//

import SwiftUI

struct EditPlanView: View {
    @EnvironmentObject private var globalVM: GlobalVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<globalVM.plans.count, id: \.self) { i in
                    let plan = globalVM.plans[i]
                    let availability = globalVM.userData.availibility[i]
                    
                    PlanCard(plan: plan, availability: availability)
                }
            }
            .padding()
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(plan.weekDay.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text(formattedTime)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Exercises List
            VStack(spacing: 0) {
                ForEach(plan.exercises, id: \.self) { exercise in
                    ExerciseRow(title: exercise.exerciseWrapper.exercise.title)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ExerciseRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Color.white
                .overlay(
                    Color.gray.opacity(0.1)
                        .opacity(0)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap action here
        }
        .overlay(
            Divider()
                .opacity(0.5),
            alignment: .bottom
        )
    }
}
