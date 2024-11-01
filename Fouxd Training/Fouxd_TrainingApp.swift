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
    @StateObject private var historyVM: WorkoutHistoryViewModel
    
    @ObservedObject private var themeService = ThemeService.shared
    
    init() {
        let planViewModel = PlanViewModel()
        _historyVM = StateObject(wrappedValue: WorkoutHistoryViewModel(plansPublisher: planViewModel.plansPublisher))
        _planViewModel = StateObject(wrappedValue: planViewModel)
    }
    
    @AppStorage("language")
    private var language: Language = {
        // First, check for previously stored language preference
        if let savedLanguageRawValue = UserDefaults.standard.string(forKey: "language"),
           let savedLanguage = Language(rawValue: savedLanguageRawValue) {
            return savedLanguage
        }
        
        // If no preference or invalid saved value, use system settings as a fallback
        let preferredLanguages = Locale.preferredLanguages
        
        // Safely map and filter preferred languages
        let matchedLanguage = preferredLanguages.compactMap { Language(rawValue: $0) }.first
        
        // Return matched language or default to English
        return matchedLanguage ?? .en
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(planViewModel)
                .environmentObject(userDataViewModel)
                .environmentObject(userSessionViewModel)
                .environmentObject(historyVM)
                .environment(\.locale, .init(identifier: language.rawValue))
                .preferredColorScheme(themeService.theme.colorScheme)
        }
    }
}
