//
//  MatchStruct.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 06/11/2021.
//

import Foundation

struct MatchStruct {
    
    let likedUserId: String
    let userId: String
    
    init(dictionary: [String : Any]) {
        self.likedUserId = dictionary["likedUserId"] as! String
        self.userId = dictionary["userId"] as! String
    }
    
}
