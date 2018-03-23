//
//  Idea.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import Foundation

class Idea {

    
    //idea
    var ideaUID : String = ""
    var date : String = ""
    var status : String = ""
    var title : String = ""
    var like : String = ""
    var dislike : String = ""
    
    init() {
        
    }
    
    init(ideaUID: String, userDict: [String : Any]){
        self.ideaUID = ideaUID
        self.date = userDict["Date"] as? String ?? "No Date"
        self.status = userDict["Status"] as? String ?? "No Status"
        self.title = userDict["Title"] as? String ?? "No Title"
    }
    
//    init(ideaUID: String, userDict: [String : Any]){
//        self.ideaUID = ideaUID
//        self.date = userDict["Date"] as? String ?? "No Date"
//        self.status = userDict["Status"] as? String ?? "No Status"
//        self.title = userDict["Title"] as? String ?? "No Title"
//    }
    
}
