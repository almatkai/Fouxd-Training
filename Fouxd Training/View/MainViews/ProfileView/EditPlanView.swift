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
            ForEach(0..<globalVM.plans.count) { i in
                let plan = globalVM.plans[i]
                let availability = globalVM.userData.availibility[i]
                
                HStack {
                    Text(plan.weekDay.rawValue)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(availability.freeTime) hours")
                }
                Divider()
                ForEach(plan.exercises, id: \.exercise.title) { exercise in
                    Text(exercise.exercise.title)
                }
                Divider().frame(height: 2)
            }
        }
    }
}
