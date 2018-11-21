//
//  ActivityTableViewCell.swift
//  MCIns
//
//  Created by Zhao on 2018/10/10.
//  Copyright © 2018年 MCgroup. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    var notification: Activity? {
        didSet {
            updateView()
        }
    }
    
    var user: InsUser? {
        didSet {
            setUpUserInfo()
        }
    }
    
    var tempUser: InsUser?
    var tempPost: Post?
    
    func updateView() {
       switch notification!.type! {
        case "newPost":
            let tapGesture_userImg = UITapGestureRecognizer(target: self, action: #selector(self.postImageViewTapped))
            self.picture.addGestureRecognizer(tapGesture_userImg)
            activityLabel.text = "added a new post"
            let postId = notification!.objectID!
            PostUtility.seekPost(withId: postId, completion: { (post) in
                self.tempPost = post
                if let photoUrlString = post.photoRef as? String {
                    let photoUrl = URL(string: photoUrlString)
                    self.picture.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
                })
        
        
        case "newComment":
            let tapGesture_userImg = UITapGestureRecognizer(target: self, action: #selector(self.postImageViewTapped))
            self.picture.addGestureRecognizer(tapGesture_userImg)
            activityLabel.text = "added a new comment"
            let postId = notification!.objectID!
            PostUtility.seekPost(withId: postId, completion: { (post) in
                self.tempPost = post
                if let photoUrlString = post.photoRef as? String {
                    let photoUrl = URL(string: photoUrlString)
                    self.picture.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
        
       case "newFollow":
        let tapGesture_userImg = UITapGestureRecognizer(target: self, action: #selector(self.userImageViewTapped))
        self.picture.addGestureRecognizer(tapGesture_userImg)
            let followedUser = notification!.objectID!
            fetchUser(uid: followedUser, completed: { (userF) in
                self.tempUser = userF
                if userF.userId != Auth.auth().currentUser?.uid {
                    self.activityLabel.text = "followed \(userF.username)"
                } else {
                    self.activityLabel.text = "followed you"
                }
                })
            picture.layer.masksToBounds = true
            picture.layer.cornerRadius = profilePic.frame.size.width / 2
            fetchUser(uid: followedUser, completed: { (userF) in
                if let photoUrlString = userF.profileImageUrl as? String {
                    let imageUrl = URL(string: photoUrlString)
                    self.picture.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
                    
            })
        
       case "newLike":
        let tapGesture_userImg = UITapGestureRecognizer(target: self, action: #selector(self.postImageViewTapped))
        self.picture.addGestureRecognizer(tapGesture_userImg)
            activityLabel.text = "liked a post"
            let postId = notification!.objectID!
            PostUtility.seekPost(withId: postId, completion: { (post) in
                self.tempPost = post
                if let photoUrlString = post.photoRef as? String {
                    let photoUrl = URL(string: photoUrlString)
                    self.picture.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
        
        default:
            print("")
        }
       if let timestamp = notification!.timestamp {
        if timestamp != ""{
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(timestamp)!)
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0{
                timeText = "\(diff.second!)s"
            }
            if diff.minute! > 0 && diff.hour! == 0{
                timeText = "\(diff.minute!)m"
            }
            if diff.hour! > 0 && diff.day! == 0{
                timeText = "\(diff.hour!)h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0{
                timeText = "\(diff.day!)d"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            timeLabel.text = timeText
        }else{
            timeLabel.text = "just"
        }
        }
    }
    
    @objc func userImageViewTapped(){
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
        vc.user = self.tempUser
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func postImageViewTapped(){
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SinglePostViewController") as! SinglePostViewController
        let post = self.tempPost
        let user = UserUtility.getLocalUserById(userId: post!.userId)
        vc.post = post
        vc.user = user
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }


    
    func fetchUser(uid: String, completed: @escaping(InsUser)->Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: dict, userId: snapshot.key)
                completed(user)
            }
        }
    }
    
    func setUpUserInfo () {
        nameLabel.text = user?.username
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        if let imageUrlString = user?.profileImageUrl{
            let imageUrl = URL(string: imageUrlString)
            self.profilePic.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImg"))
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
