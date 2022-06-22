//
//  LikeStruct.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 06/11/2021.
//

import Foundation
import Firebase

struct LikeStruct {
    
    let userThatILikeId: [String]
    let userThatLikedMeId: [String]
    
    var likeToDictionary: [String : Any] {
        return ["userThatILikeId" : self.userThatILikeId, "userThatLikedMeId" : self.userThatLikedMeId]
    }
    
    func saveToFirestore(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreReference(.Like).document(id).setData(self.likeToDictionary)
    }
}
