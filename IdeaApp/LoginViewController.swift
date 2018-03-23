//
//  ViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 21/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userChecking()
        buttonDisable()
    }
    
    func buttonDisable() {
        signInButton.isEnabled = false
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.isEmpty == false {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else {
                signInButton.isEnabled = false
                return
        }
        signInButton.isEnabled = true
    }
    
    func userChecking () {
        ref.child("User").observe(.childAdded) { (snapshot) in
            guard let currentUser = Auth.auth().currentUser?.uid else {return}

            if Auth.auth().currentUser != nil && currentUser == snapshot.key {
                guard let navVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else {return}

                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func signInTapped() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let validError = error {
                //show Alert
                self.showAlert(withTitle: "Error", message: validError.localizedDescription)
            }
            if user != nil {
                guard let navVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else {return}
                
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
}

