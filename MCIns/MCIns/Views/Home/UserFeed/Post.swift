//
//  Post.swift
//  MCIns
//
//  Created by Charles Huang on 20/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation

class Post{
    let postID: String
    let profilePic: String
    let username: String
    let postImage: String
    let likeCount: Int
    let timestamp: Int
    
    init(postID: String, profilePic: String, username: String, postImage: String, likeCount: Int, timestamp: Int){
        self.postID = postID
        self.postImage = postImage
        self.profilePic = profilePic
        self.timestamp = timestamp
        self.username = username
        self.likeCount = likeCount
    }
    
    func returnPostAsDictionary()->NSDictionary{
        let postDictionary: NSDictionary = ["postID": postID, "profile_pic": profilePic, "username": username, "posted_pic": postImage, "likeCount":likeCount, "timestamp": timestamp]
        return postDictionary
    }
}

extension Post: Equatable{
    static public func ==(rhs: Post, lhs: Post)->Bool{
        return rhs.postID == lhs.postID
    }
}
