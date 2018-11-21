//
//  LikeViewController.swift
//  MCIns
//
//  Created by Charles Huang on 16/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseDatabase


class LikeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var likeUsers = [InsUser]()
    var postID: String!
    //var currentPost = Post()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Likes"
        loadUsers()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "DiscoverSearchPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscoverSearchPeopleTableViewCell")
    }
    
    func loadUsers(){
        let likeUserRef = Database.database().reference().child("posts").child(postID).child("likes")
        likeUserRef.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            self.fetchUser(uid: uid, completed: {
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping()->Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: dict, userId: uid)
                FollowUtility.isFollowing(userId: user.userId, callback: { (isFollowing) in
                    user.isFollowing = isFollowing
                    self.likeUsers.append(user)
                    completed()
                })
            }
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverSearchPeopleTableViewCell", for: indexPath) as? DiscoverSearchPeopleTableViewCell{
            cell.user = likeUsers[indexPath.row]
            return cell
        } else{
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
        vc.user = likeUsers[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
