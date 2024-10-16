//
//  Fouxd_TrainingApp.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
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
    @StateObject private var globalVars = GlobalVM()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalVars)
        }
    }
}
