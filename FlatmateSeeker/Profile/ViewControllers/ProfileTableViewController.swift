//
//  ProfileTableViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 31/10/2021.
//

import UIKit
import Firebase
import Gallery
import ProgressHUD
import IQKeyboardManagerSwift

class ProfileTableViewController: UITableViewController, UITextViewDelegate, DislikeDelegate, MatchDelegate {
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
    @IBOutlet weak var avatarImage: UIImageView!
    var gallery: GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionView.delegate = self
        FirestoreListener.sharedInstance.listenForMatchChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirestoreListener.sharedInstance.delegate = self
        setUpBackground()
        setupProfileInformation()
        setupBackgroundTouch()
        IQKeyboardManager.shared.enable = true
    }
    
    func setUpBackground(){
        self.tableView.separatorColor = self.tableView.backgroundColor
        self.tableView.tableFooterView = nil;
        pictureBackgroundVIew.clipsToBounds = true
        pictureBackgroundVIew.layer.cornerRadius = 100
        pictureBackgroundVIew.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        tableView.footerView(forSection: 1)?.backgroundColor = UIColor(named: "MyColor")
        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = 100
    }
    
    func setupProfileInformation() {
        ProgressHUD.show()
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
        
        FirestoreListener.sharedInstance.getFromCloud(id: Auth.auth().currentUser!.uid, { image in
            if let image = image {
                self.avatarImage.image = image
            }
            ProgressHUD.dismiss()
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DataManager.sharedInstance.updateUser(key: "userDescription", value: textView.text ?? "")
        let user = DataManager.sharedInstance.retriveCurrentUserObject()
        FirestoreListener.sharedInstance.saveUserToFireStore(user: user)
    }
    
    func preferencesChosen(_ preferences: [String : Bool]) {
        let newLiked = Array(preferences.filter { $0.value == true }.keys.map { $0.replacingOccurrences(of: "_", with: " ") }) as [String]
        let newDisliked = Array(preferences.filter { $0.value == false }.keys.map { $0.replacingOccurrences(of: "_", with: " ") }) as [String]
        
        DataManager.sharedInstance.updateUser(key: "liked", value: newLiked)
        DataManager.sharedInstance.updateUser(key: "disliked", value: newDisliked)
        let user = DataManager.sharedInstance.retriveCurrentUserObject()
        FirestoreListener.sharedInstance.saveUserToFireStore(user: user)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor(named: "MyColor")
        view.tintColor = UIColor(named: "MyColor")
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
    
    @IBAction func editButtonPressed(_ sender: Any) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "InformationViewController") as! InformationViewController
        secondVC.modalPresentationStyle = .fullScreen
        self.present(secondVC, animated:true, completion:nil)
         
    }
    
    private func setupBackgroundTouch() {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func showGallery() {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    @IBAction func changePictureButton(_ sender: Any) {
        ProgressHUD.show()
        showGallery()
    }
    
    @objc func backgroundTap(){
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func presentNewMatch(_ match: MatchStruct) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "ItsAMatchViewController") as! ItsAMatchViewController
        secondVC.matchedId = match.likedUserId
        secondVC.modalPresentationStyle = .overCurrentContext
        self.present(secondVC, animated:true, completion:nil)
    }
}

extension ProfileTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { img in
                if let img = img {
                    self.avatarImage.image = img
                    FirestoreListener.sharedInstance.uploadToCloud(image: img)
                    ProgressHUD.dismiss()
                }
            }
        }
        controller.dismiss(animated: true, completion: nil)
        ProgressHUD.dismiss()
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
