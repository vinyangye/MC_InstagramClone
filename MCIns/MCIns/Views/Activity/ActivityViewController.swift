//
//  ActivityViewController.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ActivityViewController: UIViewController{
    
    @IBOutlet weak var mytableView: UITableView!
    var notifications = [Activity]()
    var users = [InsUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadActivity()
        mytableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadActivity(){
        ActivityUtility.observeActivity(id: UserUtility.getCurrentUserId()!, completion: {
            notification in
            guard let uid = notification.from else {
                return
            }
            self.fetchUser(uid: uid, completed: { (user) in
                if uid != UserUtility.getCurrentUserId(){
                    FollowUtility.isFollowing(userId: uid, callback: { (isFollowing) in
                        if isFollowing {
                            self.notifications.append(notification)
                            user.isFollowing = isFollowing
                            self.users.append(user)
                            self.mytableView.reloadData()
                        }
                    })
                }
            })
        })
    }
    
    func fetchUser(uid: String, completed: @escaping(InsUser)->Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: dict, userId: snapshot.key)
                completed(user)
            }
        }
    }
}

extension ActivityViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = mytableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        
        let noti = notifications[indexPath.row]
        let user = users[indexPath.row]
        myCell.notification = noti
        myCell.user = user
        print(noti)
        return myCell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if notifications[indexPath.row].type == "newFollow" {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
            let followedUser = notifications[indexPath.row].objectID!
            fetchUser(uid: followedUser, completed: { (userF) in
                vc.user = userF
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
        }else{
            let postId = notifications[indexPath.row].objectID!
            PostUtility.seekPost(withId: postId, completion: { (post) in
                let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SinglePostViewController") as! SinglePostViewController
                let user = UserUtility.getLocalUserById(userId: post.userId)
                vc.post = post
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
