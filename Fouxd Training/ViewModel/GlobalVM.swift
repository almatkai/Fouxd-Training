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
    @Published var userData: UserData = UserData()
    
    private init() {
        self.screenWidth = UIScreen.main.bounds.width
        self.screenHeight = UIScreen.main.bounds.height
    }
    
    func refreshUser() {
        userSession = Auth.auth().currentUser
    }
    
    func saveUserData() {
        if let user = userSession {
            DBUserDataService.shared.createUserData(uid: user.uid, data: userData)
        } else {
            LocalUserDataService.shared.saveUserDataLocally(data: userData)
        }
    }
}
