//
//  MyPostsUtility.swift
//  MCIns
//
//  Created by PaddyChang on 17/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MyPostsUtility {
    static let MY_POSTS = Database.database().reference().child("MyPosts")

    class func getMyPosts(userId: String, completion: @escaping (String) -> Void){
        MY_POSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    class func getCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        MY_POSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            print(count)
            completion(count)
        })
    }
    
}
