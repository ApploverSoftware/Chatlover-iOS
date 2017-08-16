//
//  RegisterUser.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login() {
        User.login(email: loginEmail.text!, password: loginPassword.text!) { (result) in
            switch result {
            case .success(let user):
                User.currentUser = user
                self.performSegue(withIdentifier: "showConversations", sender: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = Auth.auth().currentUser {
            User.info(forUserId: currentUser.uid) { (result) in
                switch result {
                case .success(let user):
                    User.currentUser = user
                    self.performSegue(withIdentifier: "showConversations", sender: nil)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

class RegisterViewController: UIViewController {
    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func register() {
        User.register(withName: registerName.text!, email: registerEmail.text!, password: registerPassword.text!, userImage: UIImage()) { result in
            switch result {
            case .success(let user):
                User.currentUser = user
                self.performSegue(withIdentifier: "showConversations", sender: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
