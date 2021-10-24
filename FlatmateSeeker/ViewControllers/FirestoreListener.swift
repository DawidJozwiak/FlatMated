//
//  FirestoreListener.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 24/10/2021.
//

import Foundation
import FirebaseAuth

class FirestoreListener {
    
    static let shared = FirestoreListener()
    
    private init() {}
    
    func getUser(userID: String) {
        FirestoreReference(.User).document(userID).getDocument(completion: { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(#file, #function, "Snapshot not found!", 1, [1,2], to: &Log.log)
                return 
            }
            
            if snapshot.exists {
         //       let user = User(_id: snapshot., _name: <#T##String#>, _city: <#T##String#>, _age: <#T##Int#>, _isMale: <#T##Bool#>, _occupation: <#T##String#>, _hasFlat: <#T##Bool#>)
            }
        })
    }
}
