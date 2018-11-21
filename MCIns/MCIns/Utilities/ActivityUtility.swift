//
//  NotificationUtility.swift
//  MCIns
//
//  Created by Zhao on 2018/10/16.
//  Copyright © 2018年 MCgroup. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class ActivityUtility {
    static let notificationREF = Database.database().reference().child("notification")
    static var notifications = [Activity]()
    static var users = [InsUser]()
    
    class func observeActivity(id: String, completion: @escaping (Activity) -> Void){
        notificationREF.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newNotify = Activity.activity(dict: dict, key: snapshot.key)
                completion(newNotify)
            }
            
        })
    }
    
//    class func loadActivity(){
//        ActivityUtility.observeActivity(completion: {
//            notification in
//            guard let uid = notification.from else {
//                return
//            }
//            fetchUser(uid: uid, completed: { (user) in
//                if uid != UserUtility.getCurrentUserId(){
//                    FollowUtility.isFollowing(userId: uid, callback: { (isFollowing) in
//                        if isFollowing {
//                            ActivityUtility.notifications.append(notification)
//                            //self.activityIndicator.stopAnimating()
//                            user.isFollowing = isFollowing
//                            ActivityUtility.users.append(user)
//                            //self.mytableView.reloadData()
//                        }
//                    })
//                }
//            })
//        })
//        
//    }
    class func fetchUser(uid: String, completed: @escaping(InsUser)->Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: dict, userId: snapshot.key)
                completed(user)
            }
        }
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
     notifications = ActivityUtility.allNotificaiton
     mytableView.reloadData()
     }*/
    
}
    
    /*class func initAllNotification() {
        
        notificationREF.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                let noti = Activity.activity(dict: dict)
                allNotificaiton.append(noti)
                
            }
        }
        
        
        
    }*/
    
    
   
    
    /*class func loadActivity(){
     guard let currentUser = Auth.auth().currentUser else {
     return
     }
        ActivityUtility.observeActivity(withId: currentUser.uid, completion: {
     notification in
     guard let uid = notification.from else {
     return
     }
     ActivityUtility.fetchUser(uid: uid, completed: {
        ActivityUtility.allNotificaiton.append(notification)
     //self.activityIndicator.stopAnimating()
     //print (self.notifications)
     
     })
     })
     /*Database.database().reference().child("notification").observe(.childAdded) { (snapshot: DataSnapshot) in
     if let dict = snapshot.value as? [String: Any]{
     let notification = Activity.activity(dict: dict)
     guard let uid = notification.from else {
     return
     }
     self.fetchUser(uid: uid, completed: {
     self.notifications.append(notification)
     //self.activityIndicator.stopAnimating()
     self.mytableView.reloadData()
     })
     }
     }*/
     }
     
     
     
     class func fetchUser(uid: String, completed: @escaping()->Void){
     Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
     if let dict = snapshot.value as? [String: Any]{
     let user = InsUser.transformUser(dict: dict)
     ActivityUtility.users.append(user)
     completed()
     }
     }
     }*/
    
    
    
    

