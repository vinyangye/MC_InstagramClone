//
//  User.swift
//  MCIns
//
//  Created by ye yang on 15/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation

class InsUser {
    var email: String = ""
    var profileImageUrl: String = ""
    var username: String = ""
    var userId: String = ""
    var isFollowing = false
}

extension InsUser {
    static func setupUser(dict: [String: Any], userId: String) -> InsUser{
        let user = InsUser()
        user.email = dict["email"] as! String
        user.profileImageUrl = dict["profileImageUrl"] as! String
        user.username = dict["username"] as! String
        user.userId = userId
        return user
    }
    

    static func transformUser(dict: [String: Any]) -> InsUser{
        let user = InsUser()
        user.email = dict["email"] as! String
        user.profileImageUrl = dict["profileImageUrl"] as! String
        user.username = dict["username"] as! String

        return user
    }
}
