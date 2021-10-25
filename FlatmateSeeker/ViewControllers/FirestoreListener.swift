//
//  FirestoreListener.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 24/10/2021.
//

import Foundation
import FirebaseAuth

class FirestoreListener {
    
    static let sharedInstance = FirestoreListener()
    
    private init() {}
    
    func downloadUserFromFirestore(user: User) {
        FirestoreReference(.User).document(user.id).getDocument(completion: { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(#file, #function, "Snapshot not found!", 1, [1,2], to: &Log.log)
                return 
            }
            if snapshot.exists {
                if !DataManager.sharedInstance.isEmpty {
                    DataManager.sharedInstance.deleteUser()
                }
                user.dictionaryToUser(dictionary: snapshot.data()!)
            }
            else {
                if !DataManager.sharedInstance.isEmpty {
                    DataManager.sharedInstance.deleteUser()
                }
                DataManager.sharedInstance.createUser(user)
                self.saveUserToFireStore(user: user)
            }
        })
    }
    
    func downloadExistingUserFromFirestore(id: String) -> User {
        var dictionary : [String : Any] = ["" : ""]
        FirestoreReference(.User).document(id).getDocument(completion: { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(#file, #function, "Snapshot not found!", 1, [1,2], to: &Log.log)
                return
            }
            if snapshot.exists {
                if !DataManager.sharedInstance.isEmpty {
                    DataManager.sharedInstance.deleteUser()
                }
                dictionary = snapshot.data()!
            }
        })
        let user = User(dictionary: dictionary)
        return user
    }
                                                                
    
    func saveUserToFireStore(user: User){
        FirestoreReference(.User).document(user.id).setData(user.userToDictionary(), completion: { (error) in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
            }
        })
    }
}
