//
//  User.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 23/10/2021.
//

import Foundation
import Firebase

public class User {
    
    let id: String
    var name: String
    var age: Int
    var city: String
    var isMale: Bool
   // var avatar: UIImage?
    var occupation: String
    var description: String
    var matchedUsers: [String]?
    var registeredDate = Date()
    var hasFlat: Bool
    
    init(_id: String, _name: String, _city: String, _age: Int, _isMale: Bool, _occupation: String, _hasFlat: Bool) {
        id = _id
        name = _name
        city = _city
        age = _age
        isMale = _isMale
        //avatar = _avatar
        hasFlat = _hasFlat
        occupation = _occupation
        description = ""
        matchedUsers = []
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func createUser(authData: AuthDataResult, name: String, city: String, age: Int, occupation: String, gender: Bool, flat: Bool, completion: @escaping (_ error: Error?) -> Void) {
        let user = User(_id: authData.user.uid, _name: name, _city: city, _age: age, _isMale: gender, _occupation: occupation, _hasFlat: flat)
        
    }
    
    
}

