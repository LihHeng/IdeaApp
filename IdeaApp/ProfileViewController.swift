//
//  ProfileViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 23/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var unstartedNoLabel: UILabel!
    @IBOutlet weak var progressNoLabel: UILabel!
    @IBOutlet weak var incompleteNoLabel: UILabel!
    @IBOutlet weak var completeNoLabel: UILabel!
    
    var ref : DatabaseReference!
    
    var notStartedCount = 0
    var inProgressCount = 0
    var completedCount = 0
    var incompleteCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadUserDetails()
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
    
    /******************************************** load User Details ********************************************/

    func loadUserDetails() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("User").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any],
                let email = value["Email"] as? String,
                let firstName = value["FirstName"] as? String,
                let lastname = value["LastName"] as? String,
                let profilePicURL = value["profilePicURL"] as? String {
                self.nameLabel.text = "\(firstName) \(lastname)"
                self.emailLabel.text = email
                self.renderImage(profilePicURL, cellImageView: self.profileImageView)
            }
        })
        
        ref.child("User").child(userID).child("Idea").observe(.childAdded) { (snapshot) in
            self.ref.child("Idea").child(snapshot.key).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let value = dataSnapshot.value as? [String:Any] else {return}
                guard let status = value["Status"] as? String else {return}
                
                if status == "Not Started" {
                    self.notStartedCount += 1
                } else if status == "In Progress" {
                    
                    self.inProgressCount += 1

                } else if status == "Completed" {
                    self.completedCount += 1

                } else if status == "Incomplete" {
                    self.incompleteCount += 1
                } else {
                    print("empty")
                }
                self.unstartedNoLabel.text = "\(self.notStartedCount)"
                self.progressNoLabel.text = "\(self.inProgressCount)"
                self.completeNoLabel.text = "\(self.completedCount)"
                self.incompleteNoLabel.text = "\(self.incompleteCount)"
            })
        }
    }// end of loadUserDetail
}
