//
//  Fouxd_TrainingApp.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI

@main
struct Fouxd_TrainingApp: App {
    @StateObject private var globalVars = GlobalVM()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalVars)
        }
    }
}
