//
//  Comment.swift
//  MCIns
//
//  Created by Charles Huang on 17/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit

class Comment: NSObject {
    var commentText: String = ""
    var uid: String = ""
    var createdAt: String = ""
}

extension Comment{
    static func transformComment(dict: [String: Any]) -> Comment{
        let comment = Comment()
        comment.commentText = dict["commentText"] as! String
        comment.uid = dict["uid"] as! String
        comment.createdAt = dict["createdAt"] as! String
        return comment
    }
}
