//
//  TestTableViewController.swift
//  MCIns
//
//  Created by Charles Huang on 19/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import PullToRefresh

class UserFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var posts = [Post]()
    var users = [InsUser]()
    var postUserMap = Dictionary<Post, InsUser>()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    let refresher = PullToRefresh()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var welcomeImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeButton: UIButton!
    
    @IBAction func welcomeButton_TouchUpInside(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation Bar
        self.navigationItem.title = "Home"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(self.rightBarButtonTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
        //Register CollectionViewCell
        tableView.register(UINib(nibName: "UserFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "UserFeedTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.addPullToRefresh(refresher) {
            self.loadPosts()
        }
        
        //Location Manager
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        welcomeButton.isHidden = true
        
        showWelcomeView()
        loadPosts()
        
    }
    deinit {
        tableView.removePullToRefresh(at: .top)
    }
    
    
    
    @objc func rightBarButtonTapped(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let timeButton = UIAlertAction(title: "Sort By Time (New To Old)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sortPostByTimeAsc()
        })
        
        let timeReverseButton = UIAlertAction(title: "Sort By Time (Old To New)", style: .default , handler: {
            (alert: UIAlertAction!) -> Void in
            self.sortPostByTimeDesc()
        })
        
        let locationButton = UIAlertAction(title: "Sort By Location (Nearest First)", style: .default) { (alert) in
            self.sortPostsByLocation()
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
    
    func sortPostByTimeAsc(){
        if posts.count > 0{
            posts.sort(by: {TimeInterval($0.createdAt)! > TimeInterval($1.createdAt)!})
            tableView.reloadData()
        }
    }
    
    func sortPostByTimeDesc(){
        if posts.count > 0{
            posts.sort(by: {TimeInterval($0.createdAt)! < TimeInterval($1.createdAt)!})
            tableView.reloadData()
        }
    }
    
    func sortPostsByLocation(){
        if posts.count > 0{
            var postDistanceMap = Dictionary<Post, CLLocationDistance>()
            for post in posts{
                postDistanceMap[post] = Double.infinity
                if post.locationLongitude != "" && post.locationLatitude != ""{
                    let longtitude = Double(post.locationLongitude)
                    let latitude = Double(post.locationLatitude)
                    let loc1 = CLLocation(latitude: latitude!, longitude: longtitude!)
                    let distance = loc1.distance(from: currentLocation!)
                    postDistanceMap[post] = distance
                    //print(postDistanceMap[post])
                }
            }
            posts.sort(by: {Double(postDistanceMap[$0]!) < Double(postDistanceMap[$1]!)})
            tableView.reloadData()
        }
    }
    
    func showWelcomeView(){
        welcomeView.isHidden = false
        welcomeImage.image = UIImage(named: "AppIcon")
        welcomeLabel.text = "Welcome to MCIns!\n\nYour feed has no posts right now, try to add some followings!"
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        welcomeLabel.textAlignment = .center
        welcomeLabel.numberOfLines = 0
        welcomeLabel.lineBreakMode = .byWordWrapping
        welcomeButton.setTitle("Go to discover page", for: .normal)
    }
    
    
    func loadPosts(){
        activityIndicator.startAnimating()
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let post = Post.setupPost(dict: dict, postId: snapshot.key)
                FollowUtility.isFollowing(userId: post.userId, callback: { (isFollowing) in
                    if isFollowing || post.userId == UserUtility.getCurrentUserId(){
                        self.fetchUser(uid: post.userId, completed: { (user) in
                            self.welcomeView.isHidden = true
                            if post.userId != UserUtility.getCurrentUserId(){
                                user.isFollowing = isFollowing
                            }
                            if !self.updateDataInfo(post: post, user: user){
                                self.users.append(user)
                                self.posts.append(post)
                                self.postUserMap[post] = user
                            }
                            self.posts.sort(by: {TimeInterval($0.createdAt)! > TimeInterval($1.createdAt)!})
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.tableView.reloadData()
                            self.tableView.endRefreshing(at: .top)
                        })
                    }else{
                    }
                })
            }
        }
    }
    
    func fetchUser(uid: String, completed: @escaping(InsUser)->Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = InsUser.setupUser(dict: dict, userId: uid)
                completed(user)
            }
        }
    }
    
    func updateDataInfo(post: Post, user: InsUser) -> Bool {
        if posts.count>0{
            for i in 0...posts.count-1{
                if post.postId == posts[i].postId{
                    posts[i] = post
                    postUserMap[post] = user
                    return true
                }
            }
        }
        return false
    }

    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "CommentSegue"{
//            let commentVC = segue.destination as! CommentViewController
//            let postId = sender as! String
//            commentVC.postID = postId
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserFeedTableViewCell", for: indexPath) as? UserFeedTableViewCell {
            let post = posts[indexPath.row]
            cell.post = post
            cell.user = postUserMap[post]
            cell.inHomeFeed = true
            return cell
        } else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = shareAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [share])
    }
    
    func shareAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            let cell = self.tableView.cellForRow(at: indexPath) as! UserFeedTableViewCell
            let objectsToShare = [cell.postImage.image]
            let activityController = UIActivityViewController(
                activityItems: objectsToShare,
                applicationActivities: nil)
            activityController.popoverPresentationController?.permittedArrowDirections = .any
            self.present(activityController, animated: true, completion: nil)
            completion(true)
        }
//        action.backgroundColor = UIColor.lightGray
        action.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
        return action
    }
    
}
