//
//  PostingViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 23/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PostingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ideaImageView: UIImageView! {
        didSet {
            
            ideaImageView.layer.borderColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1.0).cgColor
            ideaImageView.layer.cornerRadius = 5.0
            ideaImageView.layer.borderWidth = 5
            
            ideaImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(findImageButtonTapped))
            ideaImageView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var datePickerTextField: UITextField! {
        didSet{
            datePickerTextField.layer.borderColor = UIColor.red.cgColor
            datePickerTextField.layer.borderWidth = 0.5
        }
    }
    
    var ref : DatabaseReference!
    let datePicker = UIDatePicker()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        showDatePicker()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler), name: Notification.Name.init("btnTapped"), object: nil)

        
        ref = Database.database().reference()
    }
    
//    @objc func notificationHandler(_ notification: Notification) {
//        if let userInfo = notification.userInfo,
//            let titleString = userInfo["title"] as? String {
//            titleLabel.text = titleString
//        }
//    }
    
    /******************************************** Upload Post ********************************************/
    
    func uploadPost() {
        guard let title = titleTextField.text,
            let description = descriptionTextField.text,
            let date = datePickerTextField.text else {return}
        guard let currentUser = Auth.auth().currentUser?.uid else {return}

        let ideaID = ref.child("Idea").childByAutoId()

        let userPost: [String:Any] = ["Title": title, "Description": description,  "Date": date]
        ref.child("Idea").child(ideaID.key).setValue(userPost)
        ref.child("User").child(currentUser).child("Idea").child(ideaID.key).setValue(true)
        
        //        //UPLOAD IMAGE TO STORAGE
        if let image = self.ideaImageView.image {
            self.uploadToStorage(image, ideaID.key)
        }

    } //end of createPost

    /******************************************** Image Picker ********************************************/

    @objc func findImageButtonTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadToStorage(_ image: UIImage, _ imagePostUID : String) {
        let storageRef = Storage.storage().reference()
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.child(uid).child(imagePostUID).putData(imageData, metadata: metaData) { (meta, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadURL = meta?.downloadURL()?.absoluteString {
                self.ref.child("Idea").child(imagePostUID).child("imageURL").setValue(downloadURL)
//                self.ref.child("User").child(uid).child("images").child(imagePostUID).setValue(downloadURL)
            }
        }
    } //end of func UploadToStorage
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ideaImageView.contentMode = .scaleAspectFit
            ideaImageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    
    /******************************************** DatePickerView ********************************************/
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        datePickerTextField.inputAccessoryView = toolbar
        datePickerTextField.inputView = datePicker
    }
    
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        datePickerTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    /******************************************** CreateButton ********************************************/
    @IBAction func createIdeaButtonTapped(_ sender: Any) {
        uploadPost()
    }
    
}
