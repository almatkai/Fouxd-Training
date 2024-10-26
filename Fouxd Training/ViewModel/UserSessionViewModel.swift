//
//  UserViewModel.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import Foundation
import FirebaseAuth

class UserSessionViewModel: ObservableObject {
    @Published var userSession: User?

    func refreshUser() {
        userSession = Auth.auth().currentUser
    }
}
