//
//  Post.swift
//  MCIns
//
//  Created by ye yang on 20/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseAuth

class Post: NSObject {
    
    var postId: String = ""
    var userId: String = ""
    var photoRef: String = ""
    var caption: String = ""
    var photos = [UIImage]()
    var createdAt: String = ""
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var locationName: String = ""
    var locationAddress: String = ""
    var locationLongitude: String = ""
    var locationLatitude: String = ""
    
}

extension Post{
    
    static func setupPost(dict: [String: Any], postId: String) -> Post{
        let post = Post()
        post.caption = dict["caption"] as! String
        post.createdAt = dict["createAt"] as! String
        post.photoRef = dict["photoRef"] as! String
        post.userId = dict["userid"] as! String
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.likeCount = dict["likeCount"] as? Int
        post.locationName = dict["locationName"] as! String
        post.locationAddress = dict["locationAddress"] as! String
        post.locationLatitude = dict["locationLatitude"] as! String
        post.locationLongitude = dict["locationLongitude"] as! String
        
        if let currentUserId = Auth.auth().currentUser?.uid{
            if post.likes != nil{
                post.isLiked = post.likes![currentUserId] != nil
            }
        }
        post.postId = postId
        return post
    }
    
}
