//
//  UserDataViewModel.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import Foundation
import FirebaseAuth

class UserDataViewModel: ObservableObject {
    @Published var userData: UserData = UserData()
    
    // TODO: Route to the Account Creation so that the user Can choose and fill in the details
    func checkAndCreateData(userId: String) async {
        do {
            let defaultUserData = UserData() // Wrong implementation
            let userData = try await FBMUserData.shared.checkAndCreateUserData(uid: userId, defaultData: defaultUserData)
            self.userData = userData
        } catch {
            print("Error: \(error)")
        }
    }
    
    func isUserDataExist(userId: String) async -> Bool {
        do {
            let userData = try await FBMUserData.shared.isUserDataExist(uid: userId)
            if let userData = userData {
                self.userData = userData
                return true
            } else {
                return false
            }
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
    func createUserData(userSession: User?) {
        if let userSession = userSession {
            FBMUserData.shared.createUserData(uid: userSession.uid, data: userData)
        } else {
            UDUserData.shared.saveUserDataLocally(data: userData)
        }
    }

    func fetchUserData(userSession: User?) {
        if let userSession = userSession {
            FBMUserData.shared.fetchUserData(uid: userSession.uid) { result in
                switch result {
                case .success(let data):
                    self.userData = data
                    print(self.userData.height)
                    print(self.userData.weight)
                case .failure(let error):
                    print("Error fetching user data: \(error)")
                }
            }
        } else {
            guard let userData = UDUserData.shared.fetchUserDataLocally() else {
                print("Error fetching user data locally")
                return
            }
            self.userData = userData
        }
    }
}
