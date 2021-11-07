//
//  InformationViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 23/10/2021.
//

import UIKit
import Firebase

class InformationViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var occupation: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var flat: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func nextButton(_ sender: Any) {
        guard let name = name.text, let city = city.text, let age = age.text, let occupation = occupation.text else {
            print(#file, #function, "UI elements could not be found", 1, [1,2], to: &Log.log)
            return
        }
        guard let age = Int(age) else {
            presentAlert(title: "Incorrect Input", message: "Age can only be a numerical value")
            return
        }
        guard !name.isEmpty && !city.isEmpty && !occupation.isEmpty else {
            presentAlert(title: "Incorrect Input", message: "Please fill all required feilds then press Next button")
            return
        }
        let user = User(_id: Firebase.Auth.auth().currentUser!.uid, _name: name, _city: city, _age: age, _isMale: gender.isEnabled, _occupation: occupation, _hasFlat: flat.isEnabled)
        if !DataManager.sharedInstance.isEmpty {
            DataManager.sharedInstance.deleteUser()
        }
        DataManager.sharedInstance.createUser(user)
        FirestoreListener.sharedInstance.addUserToLikeDocument()
        FirestoreListener.sharedInstance.saveUserWithCompletionHandler(user: user) { user in
            self.performSegue(withIdentifier: "registrationCompleted", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .fullScreen
    }
    
    func presentAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
