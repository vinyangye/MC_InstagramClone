//
//  FollowUtility.swift
//  MCIns
//
//  Created by ye yang on 17/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FollowUtility{
    static let followerRef = Database.database().reference().child("followers")
    private static var followingRef = Database.database().reference().child("following")
    
    
    class func initAllFollowInfo() {
        
    }
    
    class func followUser(targetUserId: String) {
        guard let currentUserId = UserUtility.getCurrentUserId() else {
            return 
        }
        MyPostsUtility.MY_POSTS.child(targetUserId).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {Database.database().reference().child("feed").child(UserUtility.getCurrentUserId()!).child(key).setValue(true)
                }
            }
        })
        followerRef.child(targetUserId).child(currentUserId).setValue(true)
        followingRef.child(currentUserId).child(targetUserId).setValue(true)
        
    }
    
    class func unfollowUser(targetUserId: String) {
        guard let currentUserId = UserUtility.getCurrentUserId() else {
            return
        }
        followerRef.child(targetUserId).child(currentUserId).setValue(NSNull())
        followingRef.child(currentUserId).child(targetUserId).setValue(NSNull())
    }
    
    class func isFollowing(userId: String, callback: @escaping (Bool) -> Void) {
        guard let currentUserId = UserUtility.getCurrentUserId() else {
            return
        }
        followerRef.child(userId).child(currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                callback(false)
            } else{
                callback(true)
            }
        }
    }
    
    /*class func getAllFollowers() {
        guard let currentUserId = UserUtility.getCurrentUserId() else {
            return
        }
        //let userRef = Database.database().reference()
        FollowUtility.followerRef.child(currentUserId).observeSingleEvent(of: .value, with: {(snapshot) in
            let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot]
                arraySnapshot?.forEach({ (child) in
                    FeedUtility.feedRef.child(child.key).updateChildValues("\(newPostId)":true)
                })
            
        })
    }*/
    
    class func getFollowers() {
        var userList = [InsUser]()
        for user in UserUtility.allUsers{
            if user.isFollowing == true {
                userList.append(user)
                print(userList)
            }
        }
    }
    
    class func localIsFollow(userId: String) -> Bool{
        guard let user = UserUtility.getLocalUserById(userId: userId) else {
            return false
        }
        return user.isFollowing
    }
    
//    class func getFollowersId(userId: String) -> [String] {
//        let idList = [String]()
//        followerRef.child(userId).observe(.childAdded) { (snapshot: DataSnapshot) in
//            if let dict = snapshot.value as? [String: Any] {
//                snapshot.key
//            }
//        }
//        return idList
//    }
//
//    class func getFollowingId(userId: String) -> [String] {
//        let idList = [String]()
//
//        return idList
//    }
    
    class func getCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        followerRef.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
    class func getCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        followingRef.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
