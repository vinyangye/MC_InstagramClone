//
//  ProfileHeaderCollectionReusableView.swift
//  MCIns
//
//  Created by PaddyChang on 27/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var profileEditButton: UIButton!
    
    
    var user: InsUser? {
        didSet{
            updateView()
        }
    }
    
    func updateView() {
        self.nameLabel.text = user?.username
        self.profileImage.setRounded()
        self.profileImage.sd_setImage(with: URL(string: user?.profileImageUrl ?? ""))
        
        
        // Update posts, followers, and followings
        MyPostsUtility.getCountMyPosts(userId: user!.userId) { (count) in
           self.postsCountLabel.text = "\(count)"
        }
        FollowUtility.getCountFollowers(userId: user!.userId) { (count) in
            self.followersCountLabel.text =  "\(count)"
        }
        FollowUtility.getCountFollowing(userId: user!.userId) { (count) in
            self.followingCountLabel.text =  "\(count)"
        }
        
        
        if user?.userId == UserUtility.getCurrentUserId(){
            profileEditButton.backgroundColor = UIColor.white
            profileEditButton.layer.borderWidth = 0.8
            profileEditButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            profileEditButton.setTitleColor(UIColor.black, for: .normal)
            profileEditButton.text("Edit Profile")
            profileEditButton.addTarget(self, action: #selector(self.editProfileAction), for: UIControlEvents.touchUpInside)
            
        } else {
            configureFollowBtn()
        }
    }
    
    @objc func editProfileAction(){
        ViewControllerUtility.getCurrentViewController()?.performSegue(withIdentifier: "ProfileSettingSegue", sender: nil)
    }
    
    func configureFollowBtn() {
        if user!.isFollowing{
            self.followingBtnUI()
        }else{
            self.followBtnUI()
        }
    }
    
    func followBtnUI() {
        profileEditButton.setTitleColor(UIColor.white, for: .normal)
        profileEditButton.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
        profileEditButton.setTitle("Follow", for: .normal)
        profileEditButton.addTarget(self, action: #selector(followAction), for: UIControlEvents.touchUpInside)
    }
    
    func followingBtnUI() {
        profileEditButton.backgroundColor = UIColor.white
        profileEditButton.layer.borderWidth = 0.8
        profileEditButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        profileEditButton.setTitleColor(UIColor.black, for: .normal)
        profileEditButton.setTitle("Following", for: .normal)
        profileEditButton.addTarget(self, action: #selector(unfollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing == false{
            FollowUtility.followUser(targetUserId: (user?.userId)!)
            followingBtnUI()
            user?.isFollowing = true
        }
        
    }
    @objc func unfollowAction() {
        if user?.isFollowing == true{
            FollowUtility.unfollowUser(targetUserId: (user?.userId)!)
            followBtnUI()
            user?.isFollowing = false
        }
    }
}
