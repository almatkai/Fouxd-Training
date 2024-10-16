//
//  GlobalVM.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI
import FirebaseAuth

class GlobalVM: ObservableObject {
    @Published var screenWidth: CGFloat
    @Published var screenHeight: CGFloat
    @Published var userSession: User?
    
    init() {
        self.screenWidth = UIScreen.main.bounds.width
        self.screenHeight = UIScreen.main.bounds.height
        self.userSession = Auth.auth().currentUser
    }
    
    func refreshUser() {
        userSession = Auth.auth().currentUser
    }
}
