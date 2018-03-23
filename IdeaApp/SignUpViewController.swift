//
//  SignUpViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 21/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!{
        didSet {
            
            userImageView.layer.borderColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1.0).cgColor
            userImageView.layer.cornerRadius = 5.0
            userImageView.layer.borderWidth = 5
            
            userImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(findImageButtonTapped))
            userImageView.addGestureRecognizer(tap)
        }
    }
    
    var ref: DatabaseReference!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        ref = Database.database().reference()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        signUpUser()
    }
    
    func buttonDisable() {
        signUpButton.isEnabled = false
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.isEmpty == false {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
        let lastName = passwordTextField.text, !lastName.isEmpty,
        let firstName = passwordTextField.text, !firstName.isEmpty,
        let confirmPassword = passwordTextField.text, !confirmPassword.isEmpty
            else {
                signUpButton.isEnabled = false
                return
        }
        signUpButton.isEnabled = true
    }
    
    func signUpUser() {
        guard let email = emailTextField.text,
            let userName = firstNameTextField.text,
            let contact = lastNameTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text else {return}
        
        if !email.contains("@") {
            //show error //if email not contain @
            showAlert(withTitle: "Invalid Email format", message: "Please input valid Email")
        } else if password.count < 1 {
            //show error
            showAlert(withTitle: "Invalid Password", message: "Password must contain 1 characters")
        } else if password != confirmPassword {
            //show error
            showAlert(withTitle: "Password Do Not Match", message: "Password must match")
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                //ERROR HANDLING
                if let validError = error {
                    self.showAlert(withTitle: "Error", message: validError.localizedDescription)
                }
                
                //HANDLE SUCESSFUL CREATION OF USER
                if let validUser = user {
                    self.firstNameTextField.text = ""
                    self.emailTextField.text = ""
                    self.lastNameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    
                    if let image = self.userImageView.image {
                        self.uploadToStorage(image)
                    }
                    
                    let userPost: [String:Any] = ["Email": email, "LastName": userName,  "FirstName": contact]
                    self.ref.child("User").child(validUser.uid).setValue(userPost)
                    
//                    let sb = UIStoryboard(name: "Detail", bundle: Bundle.main)
                    guard let navVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else {return}
                    self.present(navVC, animated: true, completion: nil)
                    print("sign up method successful")
                }
            })
        }
    } //end of signUpUser
    
    @objc func findImageButtonTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadToStorage(_ image: UIImage) {
        let storageRef = Storage.storage().reference()
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        guard let userID = Auth.auth().currentUser?.uid else {return}

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.child(userID).child("userProfilePic").putData(imageData, metadata: metaData) { (meta, error) in
            
            if let validError = error {
                print(validError.localizedDescription)
            }
            if let downloadURL = meta?.downloadURL()?.absoluteString {
                self.ref.child("User").child(userID).child("profilePicURL").setValue(downloadURL)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImageView.contentMode = .scaleAspectFit
            userImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
