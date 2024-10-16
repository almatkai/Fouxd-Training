//
//  ContentView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI
import SVGKit

struct ContentView: View {

    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    var body: some View {
        VStack {
            if isFirstLaunch {
                FirstLaunchSetupView()
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))
            } else {
                MainView()
            }
        }
    }
}

#Preview {
    ContentView()
}
