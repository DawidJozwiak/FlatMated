//
//  SwipeViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 01/11/2021.
//

import UIKit
import Shuffle_iOS
import Firebase
import ProgressHUD

class SwipeViewController: UIViewController, SwipeCardStackDelegate, SwipeCardStackDataSource, MatchDelegate {
    
    private let stack = SwipeCardStack()
    private var cards: [UserSwipeModel] = []
    private var usersArray: [User] = []
    private func layoutCardsStack() {
        stack.delegate = self
        stack.dataSource = self
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = UserSwipeCard()
        card.footerHeight = 100
        card.swipeDirections = [.left, .right]
        for direction in card.swipeDirections {
            card.setOverlay(UserSwipeOverlay(direction: direction), forDirection: direction)
        }
        card.configure(withModel: cards[index])
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return cards.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirestoreListener.sharedInstance.listenForMatchChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FirestoreListener.sharedInstance.delegate = self
        let liked = DataManager.sharedInstance.retrieveUser()?.value(forKey: "liked") as! [String]
        let disliked = DataManager.sharedInstance.retrieveUser()?.value(forKey: "disliked") as! [String]
        let city = DataManager.sharedInstance.retrieveUser()?.value(forKey: "city") as! String
        let id = DataManager.sharedInstance.retrieveUser()?.value(forKey: "id") as! String
        FirestoreListener.sharedInstance.getLikedUsers { string in
            FirestoreListener.sharedInstance.downloadExistingUserFromFirestore(id: id) { user in
                self.getUsers(liked: liked, disliked: disliked, city: city, matched: user!.matchedUsers, swipedUsers: string ?? [])
            }
        }
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("lmao")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let matchedUserId = cards[index].id
        let dictionary = ["likedUserId" : matchedUserId, "userId" : id]
        if(direction == .right){
            FirestoreListener.sharedInstance.checkIfAnotherUserMatchedAsWell(id: matchedUserId) { isMatched in
                if(isMatched){
                    FirestoreListener.sharedInstance.updateLikeToFirestore(id: matchedUserId, property: ["userThatLikedMeId":FieldValue.arrayUnion([id]) ])
                    FirestoreListener.sharedInstance.updateUserToFirestore(id: id, property: ["matchedUsers" : FieldValue.arrayUnion([matchedUserId])])
                    FirestoreListener.sharedInstance.updateUserToFirestore(id: matchedUserId, property: ["matchedUsers" : FieldValue.arrayUnion([id])])
                    DataManager.sharedInstance.updateUser(key: "matchedUsers", value: FieldValue.arrayUnion([matchedUserId]))
                    self.presentNewMatch(MatchStruct(dictionary: dictionary))
                }
                else {
                    FirestoreListener.sharedInstance.updateLikeToFirestore(id: matchedUserId, property: ["userThatLikedMeId":FieldValue.arrayUnion([id]) ])
                    FirestoreListener.sharedInstance.updateLikeToFirestore(id: id, property: ["userThatILikeId":FieldValue.arrayUnion([matchedUserId]) ])
                }
            }
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        self.presentAlert(description: self.cards[index].description) 
    }
    
    private func getUsers(liked: [String], disliked: [String], city: String, matched: [String], swipedUsers: [String]){
        ProgressHUD.show()
        FirestoreListener.sharedInstance.downloadUsersToSwiping(city: city) { [self] users in
            guard let users = users, users.count != 0 else {
                ProgressHUD.dismiss()
                return
            }
            users.forEach { $0.score = rateUser(user: $0, yourLiked: liked, yourDisliked: disliked)}
            self.usersArray = users
            for user in self.usersArray {
                FirestoreListener.sharedInstance.getFromCloud(id: user.id) { image in
                    let card = UserSwipeModel(id: user.id, name: user.name, city: user.city, age: user.age, occupation: user.occupation, image: image ?? UIImage(named: "emptyImage"), description: user.description, hasFlat: user.hasFlat, isMale: user.isMale, score: user.score ?? 0)
                    self.cards.append(card)
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        self.cards = cards.sorted(by: { $0.score > $1.score }).filter { !matched.contains($0.id) && !swipedUsers.contains($0.id) }
                        self.layoutCardsStack()
                    }
                }}
        }
    }

    func presentNewMatch(_ match: MatchStruct) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "ItsAMatchViewController") as! ItsAMatchViewController
        secondVC.matchedId = match.likedUserId
        secondVC.modalPresentationStyle = .overCurrentContext
        self.present(secondVC, animated:true, completion:nil)
    }
    
    private func rateUser(user: User, yourLiked: [String], yourDisliked: [String])  -> Int{
        var score = 0
        score += user.liked.filter(yourLiked.contains).count
        score += user.disliked.filter(yourDisliked.contains).count
        score -= yourDisliked.filter(user.liked.contains).count * 2
        score -= yourLiked.filter(user.disliked.contains).count * 2
        return score
    }
    
    
    private func presentAlert(description: String){
        let alert = UIAlertController(title: "About me", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
