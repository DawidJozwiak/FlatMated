//
//  RegisterViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 23/10/2021.
//

import UIKit
import Firebase
import simd

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var termsSwitch: UISwitch!
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func presentAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        guard let userEmail = email.text, let userPassword = password.text, let confirmPassword = confirmPassword.text else {
            print(#file, #function, "Text fields could not be found", 1, [1,2], to: &Log.log)
            return
        }
        guard !userEmail.isEmpty && !userPassword.isEmpty && !confirmPassword.isEmpty else {
            presentAlert(title: "Incorrect Input", message: "Please fill all required feilds then press Next button")
            return
        }
        guard confirmPassword == userPassword else {
            presentAlert(title: "Incorrect Input", message: "Password fields contain two different values!")
            return
        }
        guard termsSwitch.isOn else {
            presentAlert(title: "Incorrect Input", message: "You have to agree to terms & conditions to proceed!")
            return
        }
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            if let error = error {
                self.presentAlert(title: "Incorrect Input", message: error.localizedDescription)
                return
            }
            authResult!.user.sendEmailVerification(completion: { error in
                if let error = error {
                    print(#file, #function, "Verification email has failed: \(error.localizedDescription)", 1, [1,2], to: &Log.log)
                }
                
            })
            self.performSegue(withIdentifier: "moreInformation", sender: self)
        }
    }
    
}

