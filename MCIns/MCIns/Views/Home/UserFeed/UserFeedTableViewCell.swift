//
//  UserFeedTableViewCell.swift
//  MCIns
//
//  Created by Charles Huang on 19/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UserFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var showAllCommentButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var geoImage: UIImageView!
    @IBOutlet weak var geoLabel: UILabel!
    var currentPost = Post()
    
    @IBAction func likeCountButton_TouchUpInside(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
        vc.postID = self.post?.postId
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showAllCommentButton_TouchUpInside(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        vc.postID = post?.postId
        vc.fromCommentImg = false
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    var inHomeFeed = true
    
    var post: Post?{
        didSet{
            setupPostInfo()
        }
    }
    
    var user: InsUser?{
        didSet{
            setupUserInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userLabel.text = ""
        captionLabel.text = ""
        
        let tapGesture_comment = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        self.commentImage.addGestureRecognizer(tapGesture_comment)
        self.commentImage.isUserInteractionEnabled = true
        
        let tapGesture_like = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        self.likeImage.addGestureRecognizer(tapGesture_like)
        self.likeImage.isUserInteractionEnabled = true
        
        let tapGesture_share = UITapGestureRecognizer(target: self, action: #selector(self.invokeShareMenu))
        self.shareImage.addGestureRecognizer(tapGesture_share)
        self.shareImage.isUserInteractionEnabled = true
        
        let tapGesture_userImg = UITapGestureRecognizer(target: self, action: #selector(self.userImageView_TouchUpInside))
        self.userImage.addGestureRecognizer(tapGesture_userImg)
        self.userImage.isUserInteractionEnabled = true
        
        
        let tapGesture_postImg = UITapGestureRecognizer(target: self, action: #selector(self.postImageView_TouchUpInside))
        self.postImage.addGestureRecognizer(tapGesture_postImg)
        self.postImage.isUserInteractionEnabled = true
        self.postImage.contentMode = .scaleAspectFill
        
        //        let swipeGesture_postImg = UISwipeGestureRecognizer(target: self, action: #selector(self.invokeShareMenu))
        //        swipeGesture_postImg.direction = .left
        //        self.postImage.addGestureRecognizer(swipeGesture_postImg)
        
    }
    
    @objc func commentImageView_TouchUpInside(){
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        vc.postID = post?.postId
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func likeImageView_TouchUpInside(){
        self.likeImage.image = UIImage(named:"likeSelected")
        let postRef = Database.database().reference().child("posts").child(post!.postId)
        incrementLikes(forRef: postRef)
        likeNotification()
    }
    
    func likeNotification() {
        let userId = UserUtility.getCurrentUserId()
        let newPostId = Database.database().reference().child("posts").child(post!.postId).key
        let timestamp = currentPost.createdAt
        //Database.database().reference().child("feed").child(userId!).child(newPostId).setValue(true)
        FollowUtility.followerRef.child(userId!).observeSingleEvent(of: .value, with: {(snapshot) in
            let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot]
            arraySnapshot?.forEach({ (child) in
                //FeedUtility.feedRef.child(child.key).updateChildValues(["\(newPostId)": true])
                let newNotificationId = ActivityUtility.notificationREF.child(child.key).childByAutoId().key
                let newNotificationRef = ActivityUtility.notificationREF.child(child.key).child(newNotificationId!)
                let notify = ["from": UserUtility.getCurrentUserId(),
                              "type": "newLike",
                              "objectId": newPostId,
                              "timeStamp": timestamp
                ]
                
                newNotificationRef.setValue(notify)
                
                
            })
            
        })
    }
    
    
    @objc func userImageView_TouchUpInside(){
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
        vc.user = self.user
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func postImageView_TouchUpInside(){
        if self.inHomeFeed{
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SinglePostViewController") as! SinglePostViewController
            vc.post = self.post!
            vc.user = self.user!
            ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
        } else{
            
        }
    }
    
    @objc func invokeShareMenu(){
        let objectsToShare = [self.postImage.image]
        let activityController = UIActivityViewController(
            activityItems: objectsToShare,
            applicationActivities: nil)
        
        // should be the rect that the pop over should anchor to
        //        activityController.popoverPresentationController?.sourceRect = view.frame
        //        activityController.popoverPresentationController?.sourceView = view
        activityController.popoverPresentationController?.permittedArrowDirections = .any
        
        // present the controller
        ViewControllerUtility.getCurrentViewController()?.present(activityController, animated: true, completion: nil)
    }
    
    //Run Transaction from Firebase
    func incrementLikes(forRef ref: DatabaseReference){
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any]{
                let post = Post.setupPost(dict: dict, postId: snapshot!.key)
                self.updateLike(post: post)
            }
        }
    }
    
    
    func setupPostInfo(){
        setupBasic()
        timeLabel.text = setupTime(timestamp: post!.createdAt)
        geoLabel.text = post?.locationName
        if geoLabel.text != ""{
            geoImage.isHidden = false
            geoLabel.isHidden = false
            geoImage.image = UIImage(named:"icon_event_location")
            geoLabel.font = UIFont.systemFont(ofSize: 12)
        }else{
            geoImage.isHidden = true
            geoLabel.isHidden = true
        }
        
        captionLabel.text = post?.caption
        if captionLabel.text == ""{
            captionLabel.text = "No Description"
            captionLabel.textColor = UIColor.lightGray
            captionLabel.font = UIFont.systemFont(ofSize: 12)
        }else{
            captionLabel.textColor = UIColor.black
            captionLabel.font = UIFont.systemFont(ofSize: 14)
        }
        if let imageUrlString = post?.photoRef{
            let imageUrl = URL(string: imageUrlString)
            self.postImage.sd_setImage(with: imageUrl)
        }
        
        //Fetch Like Count
        Database.database().reference().child("posts").child(post!.postId).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                self.updateLike(post: post)
            }
        }
        
        //Update like count when like increases
        Database.database().reference().child("posts").child(post!.postId).observe(.childChanged) { (snapshot) in
            if let count = snapshot.value as? Int{
                if count != 0{
                    self.likeCountButton.setTitle("\(count) likes", for: .normal)
                }else{
                    self.likeCountButton.setTitle("Be the first like this", for: .normal)
                }
            }
        }
    }
    
    func setupTime(timestamp: String) -> String{
        
        var descriptionText: String = ""
        let postTimeInterval = TimeInterval(timestamp)
        let postTime = Date(timeIntervalSince1970: postTimeInterval!)
        let currentTime = Date(timeIntervalSinceNow: 0)
        let timeInterval = currentTime - postTime
        let intTimeInterval = Int(timeInterval)
        let day = intTimeInterval/86400 >= 1 ? String((intTimeInterval / 86400)) + " days" : ""
        let hour = (intTimeInterval % 86400) / 3600 >= 1 ? String((intTimeInterval % 86400) / 3600) + " hours" : ""
        let minute = (intTimeInterval % 3600) / 60 >= 1 ? String((intTimeInterval % 3600) / 60) + " minutes" : ""
        
        if day != ""{
            descriptionText = day + " ago"
        }else if hour != ""{
            descriptionText = hour + " ago"
        }else if minute != ""{
            descriptionText = minute + " ago"
        }else{
            descriptionText = "Just now"
        }
        
        return descriptionText
    }
    
    func updateLike(post: Post){
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImage.image = UIImage(named: imageName)
        if let count = post.likeCount, count != 0{
            likeCountButton.setTitle("\(count) likes", for: .normal)
        }else if post.likeCount == 0 || post.likeCount == nil{
            likeCountButton.setTitle("Be the first like this", for: .normal)
        }
    }
    
    func setupUserInfo(){
        userLabel.text = user?.username
        if let imageUrlString = user?.profileImageUrl{
            let imageUrl = URL(string: imageUrlString)
            self.userImage.sd_setImage(with: imageUrl)
            self.userImage.setRounded()
        }
    }
    
    func setupBasic(){
        self.commentImage.image = UIImage(named: "Comment")
        self.shareImage.image = UIImage(named: "share")
        self.showAllCommentButton.setTitle("View All Comments", for: .normal)
        self.showAllCommentButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
}
