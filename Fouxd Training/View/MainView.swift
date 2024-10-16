//
//  MainView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 16.10.2024.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    
    var body: some View {
        Text("HELLO WORLD!")
        Button(action: {
            isFirstLaunch = true
        }){
            Text("RESET")
        }
        
        Button {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        } label: {
            Text("Log Out")
        }
    }
}

#Preview {
    MainView()
}
