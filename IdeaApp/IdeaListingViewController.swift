//
//  IdeaListingViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class IdeaListingViewController: UIViewController {

    @IBOutlet weak var ideaTableView: UITableView!
    
    var ref: DatabaseReference!
    var ideas : [Idea] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ideaTableView.dataSource = self
        ideaTableView.delegate = self
        ref = Database.database().reference()
        observeIdeas()
    }
    
    func observeIdeas() {
        guard let currentUerUID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("User").child(currentUerUID).child("Idea").observe(.childAdded) { (snapshot) in
            self.ref.child("Idea").child(snapshot.key).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let userDict = dataSnapshot.value as? [String:Any] else {return}
                let idea = Idea(ideaUID: snapshot.key, userDict: userDict)
                
                DispatchQueue.main.async {
                    self.ideas.append(idea)
                    let indexPath = IndexPath(row: self.ideas.count - 1, section: 0)
                    self.ideaTableView.insertRows(at: [indexPath], with: .automatic)
                }
            })
        }
        
    } //end of observeDoctorNotes
    
}

extension IdeaListingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("ListingTableViewCell", owner: self, options: nil)?.first as? ListingTableViewCell else {return UITableViewCell()}
        
        cell.dateLabel.text = ideas[indexPath.row].date
        cell.IdeaLabel.text = ideas[indexPath.row].title
        cell.statusLabel.text = ideas[indexPath.row].status
        
        return cell
    }
}

extension IdeaListingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        cell.contentView.backgroundColor = UIColor.colourSelection()
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "IdeaDetailViewController") as? IdeaDetailViewController else {return}
        
        let idea = ideas[indexPath.row]
        vc.selectedIdea = idea
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

