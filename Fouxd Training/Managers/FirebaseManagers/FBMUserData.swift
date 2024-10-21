//
//  DataBaseService.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 17.10.2024.
//

import FirebaseFirestore

enum DBError: Error {
    case invalidField
    case noDocument
}

class FBMUserData {
    
    static let shared = FBMUserData()
    private let db = Firestore.firestore()
    private let userCollection = "user_data"
    
    private init() {}
    
    func fetchUserData(uid: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let docRef = db.collection(userCollection).document(uid)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                print("No user document found")
                completion(.failure(DBError.noDocument))
                return
            }
            
            do {
                let userData = try document.data(as: UserData.self)
                completion(.success(userData))
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func createUserData(uid: String, data: UserData) {
        let docRef = db.collection(userCollection).document(uid)
        
        do {
            try docRef.setData(from: data) { error in
                if let error = error {
                    print("Error creating user data: \(error.localizedDescription)")
                } else {
                    print("User data successfully created")
                }
            }
        } catch {
            print("Error encoding user data: \(error.localizedDescription)")
        }
    }
    
    func updataUserData(uid: String, data: UserData, field: String, value: Any) {
        let docRef = db.collection(userCollection).document(uid)
        
        guard let _ = UserData.CodingKeys(stringValue: field) else {
            print("Invalid field name: \(field)")
            return
        }
        
        docRef.updateData([field: value]) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                print("User data successfully updated")
            }
        }
    }
    
    func deleteUserData(uid: String) {
        let docRef = db.collection(userCollection).document(uid)
        
        docRef.delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
            } else {
                print("User data successfully deleted")
            }
        }
    }
    
    private func handleError(_ error: Error, operation: String) {
        print("Error during \(operation): \(error.localizedDescription)")
    }
}

