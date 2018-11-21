//
//  DiscoverSearchPeopleTableViewCell.swift
//  MCIns
//
//  Created by ye yang on 15/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class DiscoverSearchPeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var followBtnWidth: NSLayoutConstraint!
    
    
    var user: InsUser? {
        didSet {
            updateCellView()
        }
    }
    
    func updateCellView() {
        usernameLabel.text = user?.username
        emailLabel.text = user?.email
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2

        configureFollowBtn()
        
        if user?.profileImageUrl != ""{
            let photoUrl = URL(string: (user?.profileImageUrl)!)
            profileImage.kf.setImage(with: photoUrl, placeholder: UIImage(named: "placeholderImg"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        
        
    }
    
    func configureFollowBtn() {
        followBtn.layer.cornerRadius = 5
        if user?.userId == UserUtility.getCurrentUserId(){
            followBtn.isHidden = true
        }else{
            if user!.isFollowing{
                self.followingBtnUI()
            }else{
                self.followBtnUI()
            }
        }
        
    }
    
    func followBtnUI() {
        followBtn.setTitleColor(UIColor.white, for: .normal)
        followBtn.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
        followBtnWidth.constant = 60
        followBtn.setTitle("Follow", for: .normal)
        followBtn.addTarget(self, action: #selector(followAction), for: UIControlEvents.touchUpInside)
    }
    
    func followingBtnUI() {
        followBtn.backgroundColor = UIColor.white
        followBtn.layer.borderWidth = 0.8
        followBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        followBtnWidth.constant = 80
        followBtn.setTitle("Following", for: .normal)
        followBtn.setTitleColor(UIColor.black, for: .normal)
        followBtn.addTarget(self, action: #selector(unfollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing == false{
            FollowUtility.followUser(targetUserId: (user?.userId)!)
            followingBtnUI()
            user?.isFollowing = true
            updateFollowSomeone()
        }
        
    }
    @objc func unfollowAction() {
        if user?.isFollowing == true{
            FollowUtility.unfollowUser(targetUserId: (user?.userId)!)
            followBtnUI()
            user?.isFollowing = false
        }
    }
    
    func updateFollowSomeone() {
        let userId = UserUtility.getCurrentUserId()
        let timestamp = ""
        //Database.database().reference().child("feed").child(userId!).child((user?.userId)!).setValue(true)
        FollowUtility.followerRef.child(userId!).observeSingleEvent(of: .value, with: {(snapshot) in
            let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot]
            arraySnapshot?.forEach({ (child) in
                //FeedUtility.feedRef.child(child.key).updateChildValues(["\(newPostId)": true])
                let newNotificationId = ActivityUtility.notificationREF.child(child.key).childByAutoId().key
                let newNotificationRef = ActivityUtility.notificationREF.child(child.key).child(newNotificationId!)
                let notify = ["from": UserUtility.getCurrentUserId(),
                              "type": "newFollow",
                              "objectId": self.user?.userId,
                              "timeStamp": timestamp
                ]
                
                newNotificationRef.setValue(notify)
                
            })
            
        })
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
