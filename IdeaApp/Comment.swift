//
//  Comment.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 23/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import Foundation

class Comment {
    
    //user
    var commentUID : String = ""
    var comment : String = ""
    var username : String = ""
    var url : String = ""
    var timestamp : String = ""
    
    init() {
        
    }
    
    init(commentUID: String, userDict: [String : Any]){
        self.commentUID = commentUID
        self.comment = userDict["Comment"] as? String ?? "No comment"
        self.username = userDict["Username"] as? String ?? "No username"
    }
    
    
}
