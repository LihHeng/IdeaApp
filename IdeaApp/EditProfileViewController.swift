//
//  EditProfileViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 23/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class EditProfileViewController: UIViewController {

    @IBOutlet weak var updateImageView: UIImageView!
    @IBOutlet weak var updateFirstNameTextField: UITextField!
    @IBOutlet weak var updateLastNameTextField: UITextField!
    
    var ref : DatabaseReference!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadUserDetails()
    }
    
    /******************************************** Load userDetails ********************************************/

    func loadUserDetails() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("User").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any],
                let firstName = value["FirstName"] as? String,
                let lastname = value["LastName"] as? String,
                let profilePicURL = value["profilePicURL"] as? String {
                self.updateFirstNameTextField.text = firstName
                self.updateLastNameTextField.text = lastname
                self.renderImage(profilePicURL, cellImageView: self.updateImageView)
            }
        })
    }
    
    func renderImage(_ urlString: String, cellImageView: UIImageView) {
        guard let url = URL.init(string: urlString) else {return}
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            if let validData = data {
                let image = UIImage(data: validData)
                DispatchQueue.main.async {
                    cellImageView.image = image
                }
            }
        }
        task.resume()
    }
    
    /******************************************** Load userDetails ********************************************/

    func updateDetails() {
        guard let firstName = updateFirstNameTextField.text,
            let lastName = updateLastNameTextField.text else {return}
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        let userPost: [String:Any] = ["FirstName": firstName, "LastName": lastName]
        ref.child("User").child(currentUser).updateChildValues(userPost)
        
        //        //UPLOAD IMAGE TO STORAGE
        if let image = self.updateImageView.image {
            self.uploadToStorage(image)
        }

    }
    
    /******************************************** Image Picker ********************************************/
    
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
                let userPost: [String:Any] = ["profilePicURL": downloadURL]
                self.ref.child("User").child(userID).child("profilePicURL").updateChildValues(userPost)
            }
        }
    } //end of func UploadToStorage
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            updateImageView.contentMode = .scaleAspectFit
            updateImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        updateDetails()
    }
    
}
