//
//  MainView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 16.10.2024.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    
    var body: some View {

        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "figure.run")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

