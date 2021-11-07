//
//  SwipeCard.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 01/11/2021.
//

import Foundation
import Shuffle_iOS

class UserSwipeCard: SwipeCard {
    
    func configure(withModel model: UserSwipeModel){
        content = UserSwipeContent(withImage: model.image)
        let gender = model.isMale ? "M" : "F"
        footer = UserSwipeFooterView(withTitle: "\(model.name) (\(model.age)\(gender))", subTitle: "\(model.occupation) looking for a flatmate in \(model.city)")//, subTitle: "About me: \(model.description)")
    }
    
}
