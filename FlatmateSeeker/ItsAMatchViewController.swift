//
//  ItsAMatchViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 06/11/2021.
//

import UIKit
import Firebase
import ProgressHUD

class ItsAMatchViewController: UIViewController {

    @IBOutlet weak var matchedName: UILabel!
    @IBOutlet weak var yourName: UILabel!
    @IBOutlet weak var yourImage: UIImageView!
    @IBOutlet weak var matchedImage: UIImageView!
    @IBOutlet weak var matchView: UIView!
    var matchedId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreListener.sharedInstance.getFromCloud(id: id) { image in
            self.yourImage.image = image ?? UIImage(systemName: "emptyImage")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProgressHUD.show()
        setBorders()
        self.yourName.text = DataManager.sharedInstance.retrieveUser()?.value(forKey: "name") as? String
        FirestoreListener.sharedInstance.downloadExistingUserFromFirestore(id: matchedId) { user in
            self.matchedName.text = user?.name ?? ""
        }
        FirestoreListener.sharedInstance.getFromCloud(id: matchedId) { image in
            self.matchedImage.image = image ?? UIImage(named: "emptyImage")
            ProgressHUD.dismiss()
            self.deleteMatchInformation()
        }
    }
    
    private func setBorders(){
        matchView.layer.cornerRadius = 10
        // border
        matchView.layer.borderWidth = 1.0
        matchView.layer.borderColor = UIColor.lightGray.cgColor
        // shadow
        matchView.layer.shadowColor = UIColor.black.cgColor
        matchView.layer.shadowOffset = CGSize(width: 3, height: 3)
        matchView.layer.shadowOpacity = 0.7
        matchView.layer.shadowRadius = 4.0
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
    }

    @IBAction func okButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func deleteMatchInformation(){
        FirestoreListener.sharedInstance.deleteUserLikedAfterMatching(matchedId: matchedId)
    }
}
