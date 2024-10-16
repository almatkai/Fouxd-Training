//
//  ContentView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI
import SVGKit

struct ContentView: View {
    
    @State private var firstSetup: Bool = UserDefaults.standard.bool(forKey: "firstSetup") == false
    
    var body: some View {
        VStack {
            FirstLaunchSetupView()
                .ignoresSafeArea()
//            if firstSetup {
                
//                VStack {
//                    Image(systemName: "globe")
//                        .imageScale(.large)
//                        .foregroundStyle(.tint)
//                    Text("Hello, world!")
//                }
//                .padding()
//                .onAppear {
//                    UserDefaults.standard.set(true, forKey: "isFirstLaunch")
//                }
//            } else {
//                EmptyView()
//            }
        }
    }
}

#Preview {
    ContentView()
}
