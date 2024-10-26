//
//  GoogleSignInAuthenticator.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 16.10.2024.
//

import Foundation
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
import Firebase
import SwiftUI

enum Status {
    case success
    case failure
    case none
}

final class GoogleSignInAuthenticator: ObservableObject {
    private unowned var avm: AuthenticationViewModel

    init(avm: AuthenticationViewModel) {
        self.avm = avm
    }

    @MainActor
    func loginWithGoogle() async -> Status {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .failure}
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return .failure}
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            return await authenticateGoogleUser(for: result.user)
        } catch {
            return .failure
        }
    }

    @MainActor
    func authenticateGoogleUser(for user: GIDGoogleUser?) async -> Status {
        guard let user = user,
              let idToken = user.idToken?.tokenString,
              let url = user.profile?.imageURL(withDimension: UInt(45 * UIScreen.main.scale))?.absoluteString else {
            
            return .failure
        }
        let accessToken = user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        do {
            try await Auth.auth().signIn(with: credential)
            
            withAnimation{
                avm.userSession = Auth.auth().currentUser
            }
            return .success
        } catch {
            return .failure
        }
    }



    func signOut() {
    GIDSignIn.sharedInstance.signOut()
        avm.userSession = nil
    }

    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { _ in
            self.signOut()
        }
    }
}
