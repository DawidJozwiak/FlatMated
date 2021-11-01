//
//  ProfileTableViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 31/10/2021.
//

import UIKit
import Firebase

class ProfileTableViewController: UITableViewController, UITextViewDelegate, DislikeDelegate {
    @IBOutlet weak var nameAge: UILabel!
    @IBOutlet weak var occupationCity: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var firstLiked: UILabel!
    @IBOutlet weak var secondLiked: UILabel!
    @IBOutlet weak var thirdLiked: UILabel!
    @IBOutlet weak var firstDisliked: UILabel!
    @IBOutlet weak var secondDisliked: UILabel!
    @IBOutlet weak var thirdDisliked: UILabel!
    @IBOutlet weak var pictureBackgroundVIew: UIView!
    @IBOutlet weak var descriptionBackgroundView: UIView!
    @IBOutlet weak var descriptionField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpBackground()
        setupProfileInformation()
        setupBackgroundTouch()
    }
    
    func setUpBackground(){
        self.tableView.tableFooterView = nil;
        pictureBackgroundVIew.clipsToBounds = true
        pictureBackgroundVIew.layer.cornerRadius = 100
        pictureBackgroundVIew.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        descriptionBackgroundView.layer.cornerRadius = 10
    }
    
    func setupProfileInformation() {
        if let id = Auth.auth().currentUser?.uid {
            FirestoreListener.sharedInstance.listenForChanges(id)
        }
        let user = DataManager.sharedInstance.retriveCurrentUserObject()
        self.descriptionView.text = user.description != "" ? user.description : "Tell me about yourself..."
        self.nameAge.text = "\(user.name), \(String(user.age))"
        self.occupationCity.text = "\(user.occupation), living in \(user.city)"
        
        let liked = user.liked
        self.firstLiked.text = liked.indices.contains(0) ? liked[0] : ""
        self.secondLiked.text = liked.indices.contains(1) ? liked[1] : ""
        self.thirdLiked.text = liked.indices.contains(2) ? liked[2] : ""
        
        let disliked = user.disliked
        self.firstDisliked.text = disliked.indices.contains(0) ? disliked[0] : ""
        self.secondDisliked.text = disliked.indices.contains(1) ? disliked[1] : ""
        self.thirdDisliked.text = disliked.indices.contains(2) ? disliked[2] : ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DataManager.sharedInstance.updateUser(key: "userDescription", value: textView.text ?? "")
        let user = DataManager.sharedInstance.retriveCurrentUserObject()
        FirestoreListener.sharedInstance.saveUserToFireStore(user: user)
    }
    
    func preferencesChosen(_ preferences: [String : Bool]) {
        let newLiked = Array(preferences.filter { $0.value == true }.keys) as [String?]
        let newDisliked = Array(preferences.filter { $0.value == false }.keys) as [String?]
        
        DataManager.sharedInstance.updateUser(key: "liked", value: newLiked)
        DataManager.sharedInstance.updateUser(key: "disliked", value: newDisliked)
        let user = DataManager.sharedInstance.retriveCurrentUserObject()
        FirestoreListener.sharedInstance.saveUserToFireStore(user: user)
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        DataManager.sharedInstance.deleteUser()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print(#file, #function, "Error logging out \(signOutError)", 1, [1,2], to: &Log.log)
        }
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "LoginScreenViewController") as! LoginScreenViewController
        secondVC.modalPresentationStyle = .fullScreen
        self.present(secondVC, animated:true, completion:nil)
    }
    
    private func setupBackgroundTouch() {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap(){
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
}
