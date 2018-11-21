//
//  HomeViewController.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var posts = [Post]()
    var users = [InsUser]()
    var isTimeAsc = true
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation Bar
        self.navigationItem.title = "Home"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(self.rightBarButtonTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
        //Register CollectionViewCell
        collectionView.register(UINib(nibName: "UserFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UserFeedCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //Load Posts
        loadPosts()
        
        //Set the UICollection View
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = CGFloat(integerLiteral: 530)
        layout.itemSize = CGSize(width: screenWidth, height: viewHeight)
        self.collectionView.collectionViewLayout = layout
        
    }
    
    @objc func rightBarButtonTapped(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let timeButton = UIAlertAction(title: "Sort By Time (New To Old)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if !self.isTimeAsc{
                self.reversePostAndUser()
                self.isTimeAsc = true
            }
        })
        
        let timeReverseButton = UIAlertAction(title: "Sort By Time (Old To New)", style: .default , handler: {
            (alert: UIAlertAction!) -> Void in
            if self.isTimeAsc{
                self.reversePostAndUser()
                self.isTimeAsc = false
            }
        })
        
        let locationButton = UIAlertAction(title: "Sort By Location (Nearest First)", style: .default) { (alert) in
            //To do
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(timeButton)
        optionMenu.addAction(timeReverseButton)
        optionMenu.addAction(locationButton)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func reversePostAndUser(){
        //sortedArray = posts.sorted(by: {TimeInterval($0.createdAt)! < TimeInterval($1.createdAt)!})
        posts.reverse()
        users.reverse()
        collectionView.reloadData()
    }
    
    
    func loadPosts(){
        activityIndicator.startAnimating()
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                self.fetchUser(uid: post.userId, completed: {
                    self.posts.append(post)
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    func fetchUser(uid: String, completed: @escaping()->Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: dict, userId: uid)
                self.users.append(user)
                completed()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postID = postId
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
//        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFeedCollectionViewCell", for: indexPath) as? UserFeedCollectionViewCell {
            let index = posts.count - 1 - indexPath.section
            let post = posts[index]
            let user = users[index]
            cell.post = post
            cell.user = user
            cell.homeVC = self
            return cell
        } else{
            return UICollectionViewCell()
        }
        
    }
    
    
    
}

