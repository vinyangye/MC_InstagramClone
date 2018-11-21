//
//  FeedUtility.swift
//  MCIns
//
//  Created by DuanXuanyu on 2018/10/18.
//  Copyright © 2018年 MCgroup. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedUtility {
    static let feedRef = Database.database().reference().child("feed")
    
    func observeFeed(withId id: String, completion: @escaping
        (Post) -> Void) {
        FeedUtility.feedRef.child(id).observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            PostUtility.seekPost(withId: key, completion: { (post) in
                completion(post)
            })
            
        })
    }
}
