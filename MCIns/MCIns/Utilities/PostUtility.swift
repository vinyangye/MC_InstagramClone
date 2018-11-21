//
//  PostUtility.swift
//  MCIns
//
//  Created by ye yang on 18/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import YPImagePicker
import FirebaseDatabase
import FirebaseStorage

private enum cancelPostStatus {
    case discard
    case draft
    case cancel
    
}

class PostUtility {
    
    
    private static let dbRef = Database.database().reference()   //database reference
    private static let storageRef = Storage.storage().reference()  //storage reference
    static let postsRef = dbRef.child("posts")
//    static var syncPostSerialQueue = DispatchQueue(label: "syncPost", attributes: [])

    static var imageRef = ""
    static var allPosts = [Post]()
    static var currentPost = Post()
    var post: Post?
    
    
    class func initAllPost() {
        
        postsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                allPosts.append(post)
                
            }
        }
        
    }
    
    //choose photo for posting
    class func choosePostPhoto(vc: UIViewController, _ callback:@escaping (photoProcessStatus,[UIImage]?)->Void) {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo, .video]
        config.screens = [.library, .photo]
        config.startOnScreen = .library
        let grid = GridView()
        config.overlayView = grid
//        config.library.maxNumberOfItems = 10
        //        config.showsCrop = .rectangle(ratio: 16/9)
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, canceled in
            
            // if the post is canceled, show the alert view
            if canceled {
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cameraButton = UIAlertAction(title: "Save Draft", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    callback(.canceled, nil)
                    picker.dismiss(animated: true, completion: nil)
                    
                })
                let libraryButton = UIAlertAction(title: "Discard", style: .default , handler: {
                    (alert: UIAlertAction!) -> Void in
                    callback(.canceled, nil)
                    currentPost = Post()
                    picker.dismiss(animated: true, completion: nil)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    callback(.canceled, nil)
                })
                
                optionMenu.addAction(cameraButton)
                optionMenu.addAction(libraryButton)
                optionMenu.addAction(cancelAction)
                
                picker.present(optionMenu, animated: true, completion: nil)
                
            }else{
                var tempimages = [UIImage]()
                for item in items {
                    switch item {
                    case .photo(let photo):
                        tempimages.append(photo.image)
                    case .video(let video):
                        print(video)
                    }
                    callback(.success, tempimages)
                }             
                let editVC = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PhotoEditViewController") as! PhotoEditViewController
                currentPost.photos = tempimages
                editVC.post = currentPost
                picker.pushViewController(editVC, animated: true)
            }
        }
        vc.present(picker, animated: true, completion: nil)
        
    }
    
    private static func setupId() {
        let userID = UserUtility.getCurrentUserId() //get user id
        currentPost.userId = userID!
        let newPostId = postsRef.childByAutoId().key //get post id
        currentPost.postId = newPostId!
        
        let timeInterval:TimeInterval = NSDate().timeIntervalSince1970
        let timeStamp = String(Int(timeInterval))
        
        currentPost.createdAt = timeStamp
        
    }
    
//    class func sharePost(_ callback:@escaping (Error?)->Void) {
//        setupId()
//        let postPhotoStorage = storageRef.child("posts").child(currentPost.postId)
//        let postImages = currentPost.photos
//        imageRef = ""
//        for image in postImages{
//            let imageData = UIImageJPEGRepresentation(image, 0.1)
//            let imageString = NSUUID().uuidString
//            imageRef = imageRef + imageString + ">"
//            let singlePhotoStorage = postPhotoStorage.child(imageString)
//            singlePhotoStorage.putData(imageData!, metadata: nil, completion: { (metadata, error) in
//                if error != nil{
//                    callback(error)
//                }
//                //                singlePhotoStorage.downloadURL { (url, error) in
//                //                    guard let downloadURL = url else {
//                //                        callback(error)
//                //                        return
//                //                    }
//                //                    temUrl = temUrl+downloadURL.absoluteString+">"
//                //                }
//            })
//        }
//        currentPost.photoRef = imageRef
//        savePostToDB()
//        currentPost = Post()
//        callback(nil)
//
//    }
    
    //New sharePost (Save image url)
    class func sharePost(_ callback:@escaping (Error?)->Void) {
        setupId()
        let postPhotoStorage = storageRef.child("posts").child(currentPost.postId)
        let postImages = currentPost.photos
        let image = postImages[0]
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        postPhotoStorage.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                callback(error)
            }
            postPhotoStorage.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    callback(error)
                    return
                }
                currentPost.photoRef = downloadURL.absoluteString
                print("FOUND URL: ", currentPost.photoRef)
                savePostToDB()
                updateNotification()
                //updateFeedNotify()
            }
        })
        callback(nil)
        
    }
    
    // save the post data in db
    private static func savePostToDB() {
        let post = ["userid": currentPost.userId,
                    "caption": currentPost.caption,
                    "createAt": currentPost.createdAt,
                    "photoRef": currentPost.photoRef,
                    "locationName": currentPost.locationName,
                    "locationAddress": currentPost.locationAddress,
                    "locationLatitude": currentPost.locationLatitude,
                    "locationLongitude": currentPost.locationLongitude]
        
        let postRef = postsRef.child(currentPost.postId)
        postRef.setValue(post)

        let myPostRef = MyPostsUtility.MY_POSTS.child(currentPost.userId).child(currentPost.postId)
        myPostRef.setValue(true) { (err, ref) in
            if err != nil {
                print(err ?? "My Posts db update error!!")
                return
            }
        }
    }
    
    
   /* class func updateNotification() {
        let newPostId = postsRef.childByAutoId().key //get post id
        let timestamp = currentPost.createdAt
        let newNotificationId = ActivityUtility.notificationREF.childByAutoId().key
        let notify = ["from": UserUtility.getCurrentUserId(),
                      "type": "newPost",
                      "objectId": newPostId,
                      "timeStamp": timestamp
        ]
        let newNotificationRef = ActivityUtility.notificationREF.child(newNotificationId!)
        newNotificationRef.setValue(notify){ (error, ref) in
            if error != nil{
                print("My Posts db update error!!")
                return
            }
            
        }
    }*/
    
    class func updateNotification() {
        let userId = UserUtility.getCurrentUserId()
        let newPostId = currentPost.postId //get post id
        //print(newPostId)
        let timestamp = currentPost.createdAt
        Database.database().reference().child("feed").child(userId!).child(newPostId).setValue(true)
        FollowUtility.followerRef.child(userId!).observeSingleEvent(of: .value, with: {(snapshot) in
            let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot]
            arraySnapshot?.forEach({ (child) in
                FeedUtility.feedRef.child(child.key).updateChildValues(["\(newPostId)": true])
                let newNotificationId = ActivityUtility.notificationREF.child(child.key).childByAutoId().key
                let newNotificationRef = ActivityUtility.notificationREF.child(child.key).child(newNotificationId!)
                let notify = ["from": UserUtility.getCurrentUserId(),
                              "type": "newPost",
                              "objectId": newPostId,
                              "timeStamp": timestamp
                ]
                
                newNotificationRef.setValue(notify)
                
            })
            
        })
    }
    
    

    class func loadPost(completion: @escaping (Post) -> Void) {

        //only observe new post add
        postsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {

                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                completion(post)
            }
            
        }
    }
    

    class func seekPost(withId id: String, completion: @escaping (Post) -> Void){
        postsRef.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                completion(post)
            }
        })
    }
  
  
    class func getDiscoverPosts() -> [Post] {
        var discoverPosts = [Post]()
        for post in allPosts{
            if post.userId != UserUtility.getCurrentUserId(){   ///NOT MY OWN POST
                if !FollowUtility.localIsFollow(userId: post.userId) {  //NOT MY FOLLOWINGS' POST
                    discoverPosts.append(post)
                }
            }
        }
        return discoverPosts
    }

    
    class func loadDiscoverPost(completion: @escaping (Post) -> Void) {
        //only observe new post add
        postsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                if post.userId != UserUtility.getCurrentUserId(){   ///NOT MY OWN POST
                    completion(post)
                }
            }
            
        }
    }
    
    class func loadDiscoverLocationPost(location: PostLocation, completion: @escaping (Post) -> Void) {
        //only observe new post add
        postsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                if post.locationName == location.name || post.locationAddress == location.address{
                    completion(post)
                }else if post.locationLongitude == location.longitude && post.locationLatitude == location.latitude{
                    completion(post)
                }
            }
            
        }
    }
    
    

}
