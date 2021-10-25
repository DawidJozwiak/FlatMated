//
//  User.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 23/10/2021.
//

import Foundation
import Firebase

public class User: Equatable {
    
    var id: String
    var name: String
    var age: Int
    var city: String
    var isMale: Bool
   // var avatar: UIImage?
    var occupation: String
    var description: String
    var matchedUsers: [String]
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
    
    init(dictionary: [String : Any]) {
        self.id = dictionary["id"] as! String
        self.name = dictionary["name"] as! String
        self.age = dictionary["age"] as! Int
        self.city = dictionary["city"] as! String
        self.isMale = dictionary["isMale"] as! Bool
        self.occupation = dictionary["occupation"] as! String
        self.description = dictionary["description"] as! String
        self.hasFlat = dictionary["hasFlat"] as! Bool
        self.matchedUsers = dictionary["matchedUsers"] as! [String]
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func userToDictionary() -> [String : Any] {
        return ["id" : self.id, "name" : self.name, "city" : self.city, "age" : self.age, "isMale" : self.isMale, "hasFlat" : self.hasFlat, "occupation" : self.occupation, "description" : self.description, "matchedUsers" : self.matchedUsers]
    }
    
    func dictionaryToUser(dictionary: [String : Any]) {
        self.id = dictionary["id"] as! String
        self.name = dictionary["name"] as! String
        self.age = dictionary["age"] as! Int
        self.city = dictionary["city"] as! String
        self.isMale = dictionary["isMale"] as! Bool
        self.occupation = dictionary["occupation"] as! String
        self.description = dictionary["description"] as! String
        self.hasFlat = dictionary["hasFlat"] as! Bool
        self.matchedUsers = dictionary["matchedUsers"] as! [String]
    }
}

