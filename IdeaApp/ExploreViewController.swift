//
//  ExploreViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 23/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ExploreViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var ideaTableView: UITableView!
    @IBOutlet weak var exploreSearchBar: UISearchBar!
    
    var ref: DatabaseReference!
    var ideas : [Idea] = []
    var currentIdeas : [Idea] = []
    var filteredData = [String]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ideaTableView.dataSource = self
        ideaTableView.delegate = self
        exploreSearchBar.delegate = self
        exploreSearchBar.returnKeyType = UIReturnKeyType.done
        ref = Database.database().reference()
        observeIdeas()
    }
    
    func observeIdeas() {
//        guard let currentUerUID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("Idea").observe(.childAdded) { (snapshot) in
            guard let userDict = snapshot.value as? [String:Any] else {return}
            let idea = Idea(ideaUID: snapshot.key, userDict: userDict)
            
            DispatchQueue.main.async {
                self.ideas.append(idea)
//                let indexPath = IndexPath(row: self.ideas.count - 1, section: 0)
//                self.ideaTableView.insertRows(at: [indexPath], with: .automatic)
                
                self.currentIdeas = self.ideas
                let indexPath = IndexPath(row: self.currentIdeas.count - 1, section: 0)
                self.ideaTableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
        
    }
    
    //search bar function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentIdeas = ideas
            ideaTableView.reloadData()
            return
        }
        
        currentIdeas = ideas.filter({ (idea) -> Bool in
            return idea.title.lowercased().contains(searchText.lowercased())
        })
        ideaTableView.reloadData()
        
    }
    
}

extension ExploreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return ideas.count
        return currentIdeas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("ListingTableViewCell", owner: self, options: nil)?.first as? ListingTableViewCell else {return UITableViewCell()}
        
//        cell.dateLabel.text = ideas[indexPath.row].date
//        cell.IdeaLabel.text = ideas[indexPath.row].title
//        cell.statusLabel.text = ideas[indexPath.row].status
        
        cell.dateLabel.text = currentIdeas[indexPath.row].date
        cell.IdeaLabel.text = currentIdeas[indexPath.row].title
        cell.statusLabel.text = currentIdeas[indexPath.row].status
        
        return cell
    }
}

extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        cell.contentView.backgroundColor = UIColor.colourSelection()
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "IdeaDetailViewController") as? IdeaDetailViewController else {return}
        
        let idea = ideas[indexPath.row]
        vc.selectedIdea = idea
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
