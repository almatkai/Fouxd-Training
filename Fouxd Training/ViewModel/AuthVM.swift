//
//  AuthVM.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 16.10.2024.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

final class AuthenticationViewModel: ObservableObject {
    @Published var userSession: User?

    private var authenticator: GoogleSignInAuthenticator {
        return GoogleSignInAuthenticator(avm: self)
    }
    
    func setup() {
        self.userSession = Auth.auth().currentUser
        
        if self.userSession != nil {
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.restorePreviousSignIn(completion: { (user, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                })
            }
            self.refreshUserStatus()
        }
    }

    func signInWithGoogle(completion: @escaping (Result<Status, Error>) -> Void) async {
        completion(.success(await authenticator.loginWithGoogle()))
    }
    
    func logOut() {
        withAnimation {
            userSession = nil
        }
        try? Auth.auth().signOut()
        authenticator.signOut()
    }
    
    func refreshUserStatus() {
        Auth.auth().currentUser?.reload(completion: { (error) in})
    }

    func disconnect() {
        authenticator.disconnect()
    }
}
