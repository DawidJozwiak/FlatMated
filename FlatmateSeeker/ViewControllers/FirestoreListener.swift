//
//  FirestoreListener.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 24/10/2021.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase

protocol MatchDelegate: AnyObject {
    func presentNewMatch(_ match: MatchStruct)
}

class FirestoreListener {
    
    static let sharedInstance = FirestoreListener()
    weak var delegate: MatchDelegate?
    let db = Firestore.firestore()
    
    private init() {}
    
    func downloadUserFromFirestore(user: User) {
        FirestoreReference(.User).document(user.id).getDocument(completion: { (snapshot, error) in
            guard let snapshot = snapshot else {
                self.saveUserToFireStore(user: user)
                return
            }
            if snapshot.exists {
                if !DataManager.sharedInstance.isEmpty {
                    let oldUser = DataManager.sharedInstance.retriveCurrentUserObject()
                    user.liked = oldUser.liked
                    user.disliked = oldUser.disliked
                    user.matchedUsers = oldUser.matchedUsers
                    user.description = oldUser.description
                    DataManager.sharedInstance.deleteUser()
                }
                DataManager.sharedInstance.createUser(user)
                self.saveUserToFireStore(user: user)
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
    
    func updateUserToFirestore(id: String, property: [String : Any]){
        FirestoreReference(.User).document(id).updateData(property)
    }
    
    func updateLikeToFirestore(id: String, property: [String : Any]){
        FirestoreReference(.Like).document(id).updateData(property)
    }
    
    func downloadExistingUserFromFirestore(id: String, _ completion: @escaping (_ user: User?) -> Void) {
        FirestoreReference(.User).document(id).getDocument(completion: { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(#file, #function, "Snapshot not found!", 1, [1,2], to: &Log.log)
                completion(nil)
                return
            }
            if snapshot.exists {
                let user = User(dictionary: snapshot.data()!)
                completion(user)
            }
            else {
                completion(nil)
                return
            }
        })
    }
    
    func getFromCloud(id: String, _ completion: @escaping (_ image: UIImage?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let avatarRef = storageRef.child("\(id).jpg")
        _ = avatarRef.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
            guard let data = data else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        })
    }
    
    func uploadToCloud(image: UIImage) {
        let storage = Storage.storage()
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = storage.reference()
        if let id = Auth.auth().currentUser?.uid {
            let photoRef = storageRef.child("\(id).jpg")
            _ = photoRef.putData(imageData, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    print(#file, #function, "Error uploading image \(String(describing: error))", 1, [1,2], to: &Log.log)
                    return
                }
            }
        }
    }
    
    func listenForChanges(_ id: String) {
        FirestoreReference(.User).document(id).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            let user = User(dictionary: data)
            DataManager.sharedInstance.deleteUser()
            DataManager.sharedInstance.createUser(user)
        }
    }
    
    func saveUserWithCompletionHandler(user: User, _ completion: @escaping (_ user: User?) -> Void) {
        FirestoreReference(.User).document(user.id).setData(user.userToDictionary(), completion: { (error) in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
                completion(nil)
            }
            else {
                completion(user)
            }
        })
    }
    
    func saveUserToFireStore(user: User){
        FirestoreReference(.User).document(user.id).setData(user.userToDictionary(), completion: { (error) in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
            }
            
        })
    }
    
    func addUserToLikeDocument(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        let emptyArray : [String] = []
        FirestoreReference(.Like).document(id).setData(["userThatLikedMeId" : emptyArray])
        FirestoreReference(.Like).document(id).updateData(["userThatILikeId" : emptyArray])
    }
    
    func listenForMatchChanges(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreReference(.Like).document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
                return
            }
            guard let snapshot = snapshot else {
                print(#file, #function, "Problem with document", 1, [1,2], to: &Log.log)
                return
            }
            guard snapshot.exists else { return }
            guard let likeData = snapshot.data() else { return }
            let likedMe = likeData["userThatLikedMeId"] as? [String] ?? []
            let iLike = likeData["userThatILikeId"] as? [String] ?? []
            let commonPart = Set(likedMe).intersection(Set(iLike))
            if !commonPart.isEmpty {
                let dictionary = ["likedUserId" : commonPart.first!, "userId" : id] as [String : Any]
                self.delegate?.presentNewMatch(MatchStruct(dictionary: dictionary))
            }
        }
    }
    
    func checkIfAnotherUserMatchedAsWell(id likedId: String, _ completion: @escaping (_ isMatched: Bool) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreReference(.Like).document(id).getDocument { snapshot, error in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
                return
            }
            guard let snapshot = snapshot else {
                print(#file, #function, "Problem with document", 1, [1,2], to: &Log.log)
                completion(false)
                return
            }
            if !snapshot.exists {
                completion(false)
                return
            }
            guard let likeData = snapshot.data() else { return }
            let likedMe = likeData["userThatLikedMeId"] as? [String] ?? []
            completion(likedMe.contains(likedId))
        }
    }
    
    func downloadUsersToSwiping(city: String, _ completion: @escaping (_ users: [User]?) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        db.collection("User").whereField("city", isEqualTo: city)
            .whereField("id", isNotEqualTo: id).getDocuments() { (snapshot, error) in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
                completion(nil)
            }
            let usersArray = snapshot?.documents.map { User(dictionary: $0.data()) }
            completion(usersArray)
        }
    }
    
    func getLikedUsers(_ completion: @escaping (_ string: [String]?) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreReference(.Like).document(id).getDocument { document, error in
            if let error = error {
                print(#file, #function, error.localizedDescription, 1, [1,2], to: &Log.log)
                return
            }
            guard let snapshot = document, let data = snapshot.data() else {
                print(#file, #function, "Problem with document", 1, [1,2], to: &Log.log)
                completion(nil)
                return
            }
            if !snapshot.exists {
                completion(nil)
                return
            }
            let likedArray = data["userThatILikeId"] as? [String] ?? []
            completion(likedArray)
        }
    }
    
    func deleteUserLikedAfterMatching(matchedId: String){
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreReference(.Like).document(id).updateData([
            "userThatLikedMeId": FieldValue.arrayRemove([matchedId])
        ])
    }
}
