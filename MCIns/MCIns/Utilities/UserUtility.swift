//
//  UserUtility.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GooglePlaces

class UserUtility {
    
    static var currentUser: InsUser?
    static let ref = Database.database().reference()
    static let storageRef = Storage.storage().reference()
    static let userRef = ref.child("users")
    static var profilePhoto: UIImage?
//    static var syncUserSerialQueue = DispatchQueue(label: "syncUser", attributes: [])
    static var allUsers = [InsUser]()
    static var userLocation = CLLocation(latitude: -37.799137, longitude: 144.96078)
    
    //sign in or not
    class func isUserSignedIn() -> Bool{
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    class func initCurrentUser() {
        let userId = UserUtility.getCurrentUserId()
        userRef.child(userId!).observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: value, userId: snapshot.key)
                currentUser = user
            }
        })
    }
    
    class func getCurrentUser( callback:@escaping (InsUser)->Void) {
        let userId = UserUtility.getCurrentUserId()
        userRef.child(userId!).observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: value, userId: snapshot.key)
                callback(user)
            }
        })
    }
    
    //get current user id
    class func getCurrentUserId() -> String?{
        if isUserSignedIn() {
            return (Auth.auth().currentUser?.uid)!
        }
        return nil
    }
        
    
    class func initAllUser() {
        userRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = InsUser.setupUser(dict: dict, userId: snapshot.key)
                FollowUtility.isFollowing(userId: user.userId, callback: { (isFollowing) in
                    user.isFollowing = isFollowing
                    allUsers.append(user)
                })
            }
        }
        
    }
    
    
    
    
    //sign up new account
    class func signUp(email: String, username: String, password: String, _ callback:@escaping (Error?,User?)->Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                callback(error, nil)
            }else{
                let uid  = authResult?.user.uid
                let profilePhotoStorage = storageRef.child("profile_image").child(uid!)
                if profilePhoto == nil{
                    profilePhoto = #imageLiteral(resourceName: "icons8-customer-128")
                }
                let profileImage = profilePhoto!
                let imageData = UIImageJPEGRepresentation(profileImage, 0.1)
                profilePhotoStorage.putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        deleteAuthUser()
                        callback(error, nil)
                    }
                    profilePhotoStorage.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            deleteAuthUser()
                            callback(error, nil)
                            return
                        }
                        
                        let profileImageUrl = downloadURL.absoluteString
                        userRef.child(uid!).setValue(["email": email, "username": username, "profileImageUrl": profileImageUrl])
                        callback(nil, authResult?.user)
                    }
                })
            }
        }
    }
    
    class func updateUserInfo(userId: String, email: String, username: String, imageData: Data, _ callback:@escaping (Error?, User?)->Void) {
        print("1111", email)
        Auth.auth().currentUser!.updateEmail(to: email, completion: { (err) in
            if err != nil {
                AlertViewUtility.showWarningView("Update failed")
            }else{
//                AlertViewUtility.showNoFunctionAlertView(message: "Successed")
            }
        })
        let userID = UserUtility.getCurrentUserId()
        let userRef = Database.database().reference(withPath: "users")
        let storageRef = Storage.storage().reference()
        let profilePhotoStorage = storageRef.child("profile_image").child(userID!)
        profilePhotoStorage.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                deleteAuthUser()
                callback(error, nil)
            }
            profilePhotoStorage.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    deleteAuthUser()
                    callback(error, nil)
                    return
                }
                
                let profileImageUrl = downloadURL.absoluteString
                userRef.child(userId).setValue(["email": email, "username": username, "profileImageUrl": profileImageUrl])
                callback(nil, nil)
            }
        })
    }
    
    private static func deleteAuthUser() {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                
            }
        }
    }
    
    //Log In
    class func signIn(email: String, password: String, _ callback:@escaping (Error?,User?)->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                callback(error, nil)
            }else{
                //                authResult?.user.
                callback(nil, authResult?.user)
            }
        }
    }
    
    //Log Out
    class func signOut() {
        do{
            try Auth.auth().signOut()
        } catch let error {
            
        }
    }
    
    //algorithm: common neighbor
    class func getSuggestedUser() -> [InsUser]{
        var userList = [InsUser]()
        var i = 0
        for user in allUsers{
            if user.userId != getCurrentUserId(){
                if user.isFollowing == false{
                    i+=1
                    userList.append(user)
                    if i == 6{
                        break
                    }
                }
            }
        }
        return userList
        
    }
    
    
    class func getSearchUser(searchText: String) -> [InsUser]{
        var userList = [InsUser]()
        for user in allUsers{
            if user.userId != getCurrentUserId(){
                if user.username.lowercased().contains(searchText){
                    userList.append(user)
                }
            }
        }
        return userList
        
    }
    
    class func getLocalUserById(userId: String) -> InsUser?{
        for user in allUsers{
            if user.userId == userId{
                return user
            }
        }
        return nil
    }
    
}
