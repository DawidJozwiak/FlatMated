//
//  FirestoreCollection.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 24/10/2021.
//

import Foundation
import FirebaseFirestore

enum FirestoreCollection: String {
    case User
    case Like
    case Messenger
}

func FirestoreReference(_ collection: FirestoreCollection) -> CollectionReference {
    return Firestore.firestore().collection("\(collection)")
}
