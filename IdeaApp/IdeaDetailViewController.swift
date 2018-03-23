//
//  IdeaDetailViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class IdeaDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var dislikeLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        uploadComment()
    }
    
    
    var selectedIdea : Idea = Idea()
    var ref : DatabaseReference!
    var comments: [Comment] = []
    var users: User = User()
    let statusPicker = UIPickerView()
    
    var status = ["Not Started", "In Progress", "Completed", "Incomplete"]

    override func viewDidLoad() {
        super.viewDidLoad()
        statusPicker.delegate = self
        statusPicker.dataSource = self
        commentTableView.dataSource = self
        statusTextField.backgroundColor = UIColor.blue
        showStatusPickerView()
        ref = Database.database().reference()
        likeImage()
        observeIdeas()
        observeComment()
        disableWhenDifferentUser()
    }

    /**************************** disable status editing for different user Post ****************************/

    func disableWhenDifferentUser() {
        guard let currentUerUID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("User").child(currentUerUID).child("Idea").observe(.childAdded) { (snapshot) in
            if snapshot.key != self.selectedIdea.ideaUID {
                self.statusTextField.allowsEditingTextAttributes = true
                self.statusTextField.isUserInteractionEnabled = true
            } else {
                self.statusTextField.allowsEditingTextAttributes = false
                self.statusTextField.isUserInteractionEnabled = false
            }
        }
        
    }
    
    /******************************************** Comments ********************************************/
    
    func observeComment() {
        guard let currentUerUID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("Idea").child(selectedIdea.ideaUID).child("Comment").observe(.childAdded) { (snapshot) in
            self.ref.child("Comment").child(snapshot.key).observe(.value, with: { (dataSnapshot) in
                guard let commentDict = dataSnapshot.value as? [String:Any] else {return}
                let comment = Comment(commentUID: dataSnapshot.key, userDict: commentDict)
                
                DispatchQueue.main.async {
                    self.comments.append(comment)
                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                    self.commentTableView.insertRows(at: [indexPath], with: .automatic)
                    self.commentTableView.reloadData()
                }
            })
        }
    }
    
    func uploadComment() {
        guard let currentUerUID = Auth.auth().currentUser?.uid else {return}
        guard let commentText = commentTextField.text else {return}
        guard let username = nameLabel.text else {return}
        let timeStamp = Date().timeIntervalSince1970
                
        let comment = self.ref.child("Comment").childByAutoId()
        let userPost : [String:Any] = ["Comment": commentText, "UserUID": currentUerUID, "Username": username, "TimeStamp": "\(timeStamp)"]
        comment.setValue(userPost)
        self.ref.child("Idea").child(self.selectedIdea.ideaUID).child("Comment").child(comment.key).setValue(true)
        
    }

    /******************************************** Observe Ideas ********************************************/

    func observeIdeas() {
        guard let currentUerUID = Auth.auth().currentUser?.uid else {return}
        titleLabel.text = selectedIdea.title
//        nameLabel.text = currentUerUID

        ref.child("Idea").child(selectedIdea.ideaUID).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String:Any] else {return}
            self.postDateLabel.text = value["Date"] as? String
            self.descriptionLabel.text = value["Description"] as? String
            guard let postImageURL = value["imageURL"] as? String else {return}
            self.renderImage(postImageURL, cellImageView: self.postImageView)
        }
        
        ref.child("User").child(currentUerUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any],
                let firstName = value["FirstName"] as? String,
                let lastname = value["LastName"] as? String {
                self.nameLabel.text = "\(firstName) \(lastname)"
                
//                self.renderImage(profilePicURL, cellImageView: self.postImageView)
            }
        })
    }
    
    /******************************************** ImageURL ********************************************/
    
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
    
    
    /******************************************** StatusPickerView ********************************************/
    
    func showStatusPickerView(){
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        statusTextField.inputAccessoryView = toolbar
        statusTextField.inputView = statusPicker
    }


    
    @objc func doneDatePicker(){
        guard let text = statusTextField.text else {return}
        ref.child("Idea").child(selectedIdea.ideaUID).child("Status").setValue(text)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

    /******************************************** Like ********************************************/

    func likeImage() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("Like").child(selectedIdea.ideaUID).observeSingleEvent(of: .value) { (snapshot) in
            if currentUserUID == snapshot.key {
                let likeImage = UIImage(named: "RedLike")
                self.likeButton.setImage(likeImage, for: .normal)
                
                let dislikeImage = UIImage(named: "GreyDislike")
                self.dislikeButton.setImage(dislikeImage, for: .normal)
            } else {
                let dislikeImage = UIImage(named: "RedDislike")
                self.dislikeButton.setImage(dislikeImage, for: .normal)
                
                let likeImage = UIImage(named: "GreyLike")
                self.likeButton.setImage(likeImage, for: .normal)

            }
        }
        
        ref.child("Dislike").child(selectedIdea.ideaUID).observeSingleEvent(of: .value) { (snapshot) in
            if currentUserUID == snapshot.key {
                let dislikeImage = UIImage(named: "RedDislike")
                self.dislikeButton.setImage(dislikeImage, for: .normal)
                
                let likeImage = UIImage(named: "GreyLike")
                self.likeButton.setImage(likeImage, for: .normal)
            } else {
                let likeImage = UIImage(named: "RedLike")
                self.likeButton.setImage(likeImage, for: .normal)
                
                let dislikeImage = UIImage(named: "GreyDislike")
                self.dislikeButton.setImage(dislikeImage, for: .normal)
            }
        }
        
        ref.child("Like").child(selectedIdea.ideaUID).observe(.value, with: { (snapshot) in
            let likeCount = snapshot.childrenCount
            print("Images Count: \(likeCount)")
            self.likeLabel.text = "\(likeCount)"
        })
        
        ref.child("Dislike").child(selectedIdea.ideaUID).observe(.value, with: { (snapshot) in
            let dislikeCount = snapshot.childrenCount
            print("Images Count: \(dislikeCount)")
            self.dislikeLabel.text = "\(dislikeCount)"
        })
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let userPost: [String:Any] = [currentUser: true]

        ref.child("Like").child(selectedIdea.ideaUID).updateChildValues(userPost)
        ref.child("Dislike").child(selectedIdea.ideaUID).child(currentUser).removeValue()
        likeButton.currentImage?.accessibilityElementsHidden = true
        
        let likeImage = UIImage(named: "RedLike")
        likeButton.setImage(likeImage, for: .normal)
        
        let dislikeImage = UIImage(named: "GreyDislike")
        dislikeButton.setImage(dislikeImage, for: .normal)
    }
    
    @IBAction func dislikeButtonTapped(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let userPost: [String:Any] = [currentUser: true]
        
        ref.child("Dislike").child(selectedIdea.ideaUID).updateChildValues(userPost)
        ref.child("Like").child(selectedIdea.ideaUID).child(currentUser).removeValue()
        dislikeButton.currentImage?.accessibilityElementsHidden = true
        
        let dislikeImage = UIImage(named: "RedDislike")
        dislikeButton.setImage(dislikeImage, for: .normal)
        
        let likeImage = UIImage(named: "GreyLike")
        likeButton.setImage(likeImage, for: .normal)
    }
    
} // end of Class

/******************************************** statusPickerView ********************************************/

extension IdeaDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return status.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return status[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statusTextField.text = status[row]
    }
}

/******************************************** Comment TableView ********************************************/

extension IdeaDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(comments.count)
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CommentTableViewCell else {return UITableViewCell()}
        
        cell.nameLabel.text = comments[indexPath.row].username
        cell.commentLabel.text = comments[indexPath.row].comment
        cell.dateLabel.text = comments[indexPath.row].timestamp
        
        return cell
    }
    
}
