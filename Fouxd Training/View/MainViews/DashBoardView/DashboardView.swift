//
//  HomeView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 17.10.2024.
//

import SwiftUI
import FirebaseAuth

//struct DashboardView: View {
//    @EnvironmentObject private var userSessionVM: UserSessionViewModel
//    @EnvironmentObject private var planVM: PlanViewModel
//    @EnvironmentObject private var userDataVM: UserDataViewModel
//    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
//    @State var plans: [Plan] = []
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text(userSessionVM.userSession?.uid ?? "NO USER ID")
//                Button(action: {
//                    isFirstLaunch = true
//                    userDataVM.userData = UserData()
//                }){
//                    Text("RESET")
//                }
//                
//                Button {
//                    do {
//                        try Auth.auth().signOut()
//                    } catch {
//                        print("Error signing out: \(error.localizedDescription)")
//                    }
//                } label: {
//                    Text("Log Out")
//                }
//                
//                Button(action: {
//                    let domain = Bundle.main.bundleIdentifier!
//                    UserDefaults.standard.removePersistentDomain(forName: domain)
//                    UserDefaults.standard.synchronize()
//                    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
//                }){
//                    Label("Delete User Default Information", systemImage: "trash")
//                }
//                
//                Button(action: {
//                    planVM.plans = PlanMakerService.shared.createPlan(userData: userDataVM.userData)
//                }){
//                    Label("Add Workout", systemImage: "plus")
//                }
//                
//                Button(action: {
//                    userSessionVM.refreshUser()
//                }){
//                    Label("Refresh User", systemImage: "arrow.clockwise")
//                }
//                
//            }
//        }
//    }
//}

import SwiftUI
import HealthKit

struct DashboardView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var isStepsExpanded = false
    @State private var isActivityExpanded = false
    @Namespace private var namespace
    @EnvironmentObject private var historyVM: WorkoutHistoryViewModel
    
    enum TimeRange {
        case week, month, year
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if isStepsExpanded {
                            MetricCard(
                                title: "Steps",
                                value: "\(Int(healthKitManager.steps))",
                                icon: "figure.walk",
                                color: .blue,
                                isExpanded: $isStepsExpanded,
                                namespace: namespace
                            ) {
                                StepsChart(data: healthKitManager.weeklySteps)
                            }
                        } else if isActivityExpanded {
                            MetricCard(
                                title: "Active Energy",
                                value: "\(Int(healthKitManager.activeEnergy)) kcal",
                                icon: "flame.fill",
                                color: .orange,
                                isExpanded: $isActivityExpanded,
                                namespace: namespace
                            ) {
                                ActivityChart(data: healthKitManager.weeklyActivity)
                            }
                        } else {
                            HStack(spacing: 16) {
                                MetricCard(
                                    title: "Steps",
                                    value: "\(Int(healthKitManager.steps))",
                                    icon: "figure.walk",
                                    color: .blue,
                                    isExpanded: $isStepsExpanded,
                                    namespace: namespace
                                ) {
                                    StepsChart(data: healthKitManager.weeklySteps)
                                }
                                
                                MetricCard(
                                    title: "Active Energy",
                                    value: "\(Int(healthKitManager.activeEnergy)) kcal",
                                    icon: "flame.fill",
                                    color: .orange,
                                    isExpanded: $isActivityExpanded,
                                    namespace: namespace
                                ) {
                                    ActivityChart(data: healthKitManager.weeklyActivity)
                                }
                            }
                        }
                        
                        WorkoutCalendarView(workoutHistories: historyVM.workoutHistory)
                            .frame(minHeight: 300)
                            .padding(.vertical)
                        
                        
                    }
                    .padding()
                }
                .onAppear {
                    healthKitManager.requestAuthorization()
                    healthKitManager.fetchHealthData()
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct MetricCard<Content: View>: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Binding var isExpanded: Bool
    let namespace: Namespace.ID
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .matchedGeometryEffect(id: "title-\(title)", in: namespace)
                        .transition(.scale.combined(with: .opacity))
                    
                    Text(value)
                        .font(.title2)
                        .bold()
                        .matchedGeometryEffect(id: "value-\(title)", in: namespace)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .matchedGeometryEffect(id: "icon-\(title)", in: namespace)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if isExpanded {
                content()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .matchedGeometryEffect(id: "chevron-\(title)", in: namespace)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .matchedGeometryEffect(id: "background-\(title)", in: namespace)
                .shadow(radius: 2)
        )
        .scaleEffect(isExpanded ? 1 : 0.95)
    }
}
