//
//  User.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import Foundation

class User {

    //user
    var uid : String = ""
    var email : String = ""
    var lastName : String = ""
    var firstName : String = ""
    var profilePicURL : String = ""
    
    init() {
        
    }
    
    init(uid: String, userDict: [String : Any]){
        self.uid = uid
        self.email = userDict["Email"] as? String ?? "No email"
        self.firstName = userDict["FirstName"] as? String ?? "No username"
        self.lastName = userDict["LastName"] as? String ?? "No username"
        self.profilePicURL = userDict["profilePicURL"] as? String ?? "No URL"
    }
    
    
}
