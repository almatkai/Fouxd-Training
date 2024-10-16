//
//  MainView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 16.10.2024.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    
    var body: some View {
        Text("HELLO WORLD!")
        Button(action: {
            isFirstLaunch = true
        }){
            Text("RESET")
        }
    }
}

#Preview {
    MainView()
}
