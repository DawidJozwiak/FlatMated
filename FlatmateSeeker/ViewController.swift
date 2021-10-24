//
//  ViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 15/10/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 2, delay: 0.0, options: .curveLinear, animations: {
            self.logo.frame.origin.y -= 270
        }, completion: {_ in
            self.displayLoginElements()
        })
    }
    
    func displayLoginElements(){
        performSegue(withIdentifier: "loginScreen", sender: self)
    }
}

