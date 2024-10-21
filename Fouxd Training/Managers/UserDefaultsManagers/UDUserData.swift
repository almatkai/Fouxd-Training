//
//  LocalUserDataService.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 19.10.2024.
//

import Foundation

class UDUserData {
    
    static let shared = UDUserData()
    
    // MARK: - UserDefaults Implementation
    private let defaults = UserDefaults.standard
    private let userDataKey = "localUserData"
    
    private init() {}
    
    // MARK: - UserDefaults Methods
    
    func saveUserDataLocally(data: UserData) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            defaults.set(encodedData, forKey: userDataKey)
            print("User data saved locally successfully")
        } catch {
            print("Error saving user data locally: \(error.localizedDescription)")
        }
    }
    
    func fetchUserDataLocally() -> UserData? {
        guard let savedData = defaults.object(forKey: userDataKey) as? Data else {
            print("No local user data found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let userData = try decoder.decode(UserData.self, from: savedData)
            return userData
        } catch {
            print("Error decoding local user data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateUserDataLocally(field: String, value: Any) {
        guard var userData = fetchUserDataLocally() else {
            print("No local user data to update")
            return
        }
        
        switch field {
        case "weight":
            if let newValue = value as? Double {
                userData.weight = newValue
            }
        case "height":
            if let newValue = value as? Double {
                userData.height = newValue
            }
        case "age":
            if let newValue = value as? Int {
                userData.age = newValue
            }
        case "gender":
            if let newValue = value as? Gender {
                userData.gender = newValue
            }
        case "availibility":
            if let newValue = value as? [Availability] {
                userData.availibility = newValue
            }
        case "activityLevel":
            if let newValue = value as? ActivityLevel {
                userData.activityLevel = newValue
            }
        default:
            print("Invalid field name: \(field)")
            return
        }
        
        saveUserDataLocally(data: userData)
    }
    
    func deleteUserDataLocally() {
        defaults.removeObject(forKey: userDataKey)
        print("Local user data deleted")
    }
}
