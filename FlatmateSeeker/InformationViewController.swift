//
//  InformationViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 23/10/2021.
//

import UIKit

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
        guard !name.isEmpty && !city.isEmpty && !age.isEmpty && !occupation.isEmpty else {
            presentAlert(title: "Incorrect Input", message: "Please fill all required feilds then press Next button")
            return
        }
      /*  Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            if let error = error {
                self.presentAlert(title: "Incorrect Input", message: error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "moreInformation", sender: self)
       }*/
    }
    
    func presentAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
