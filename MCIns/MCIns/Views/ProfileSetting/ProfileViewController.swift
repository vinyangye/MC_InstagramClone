//
//  ProfileViewController.swift
//  MCIns
//
//  Created by PaddyChang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    var user: InsUser?
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUser()
        setupBasic()
        getMyPosts()
    }
    
    
    func setupBasic() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupUser() {
        user = UserUtility.currentUser
    }

    func fetchUser(){
        let ref = Database.database().reference()
        let userRef = ref.child("users")
        let userId = UserUtility.getCurrentUserId()
        userRef.child(userId!).observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any]{
                self.user = InsUser.setupUser(dict: value, userId: snapshot.key)
            }
        })
    }
    
    func getMyPosts() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        MyPostsUtility.MY_POSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            PostUtility.seekPost(withId: snapshot.key, completion: {
                post in
                self.posts.insert(post, at: 0)
//                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "ProfileSettingSegue" {
            let settingVC = segue.destination as! ProfileEditTableViewController
            settingVC.Delegate = self
        }
    }
    
    
    @IBAction func addBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "AddUserViewController") as! AddUserViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ProfileCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderCollectionView", for: indexPath) as! ProfileHeaderCollectionReusableView
        headerViewCell.user = self.user
        return headerViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCollectionViewCell
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SinglePostViewController") as! SinglePostViewController
        let post = cell.post
        let user = UserUtility.getLocalUserById(userId: post!.userId)
        vc.post = post
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1 , height: collectionView.frame.size.width / 3 - 1)
    }
}

extension ProfileViewController: ProfileEditTableViewControllerDelegate {
    func updateUserInfo() {
        fetchUser()
        self.collectionView.reloadData()
    }
}
