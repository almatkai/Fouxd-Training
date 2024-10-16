//
//  ContentView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI
import SVGKit

struct ContentView: View {
    // Define a property to check if the first launch setup is complete
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    var body: some View {
        VStack {
            if isFirstLaunch {
                FirstLaunchSetupView()
                    .ignoresSafeArea()
                    .onAppear {
                        print("First launch setup")
                    }
                    .onDisappear {
                        isFirstLaunch = false
                    }
            } else {
                MainView()
            }
        }
    }
}

#Preview {
    ContentView()
}
