//
//  Fouxd_TrainingApp.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 15.10.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct Fouxd_TrainingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var planViewModel = PlanViewModel()
    @StateObject private var userDataViewModel = UserDataViewModel()
    @StateObject private var userSessionViewModel = UserSessionViewModel()
    @StateObject private var historyVM = WorkoutHistoryViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(planViewModel)
                .environmentObject(userDataViewModel)
                .environmentObject(userSessionViewModel)
                .environmentObject(historyVM)
        }
    }
}
