//
//  LoginScreenViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 17/10/2021.
//

import UIKit
import Firebase
import ProgressHUD

class LoginScreenViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        guard let userEmail = email.text, let userPassword = password.text else {
            print(#file, #function, "Text fields could not be found", 1, [1,2], to: &Log.log)
            return
        }
        guard !userEmail.isEmpty && !userPassword.isEmpty else {
            presentAlert(title: "Incorrect Input", message: "Please fill all required feilds then press Next button")
            return
        }
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: userEmail, password: userPassword, completion: { (authDataResult, error) in
            if let error = error {
                self.presentAlert(title: "Incorrect Input", message: error.localizedDescription)
                return
            }
            ProgressHUD.dismiss()
            self.performSegue(withIdentifier: "loggingCompleted", sender: self)
        })
    }
    
    func presentAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
