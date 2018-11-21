//
//  CommentViewController.swift
//  MCIns
//
//  Created by Charles Huang on 1/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var currentPost = Post()
    var comments = [Comment]()
    var users = [InsUser]()
    var postID: String!
    var fromCommentImg = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Comment"
        sendButton.isEnabled = false
        handleTextField()
        loadComments()
        
        commentTextField.placeholder = "Comment"
        if fromCommentImg{
            commentTextField.becomeFirstResponder()
        }
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tableView.tableFooterView = UIView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func hideKeyboard(){
        let tap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        var keyboardHeight = keyboardFrame!.height
        if #available(iOS 11.0, *) {
            let bottomInset = self.view.safeAreaInsets.bottom
            keyboardHeight -= bottomInset
        }
        UIView.animate(withDuration: 0.3) {
            //print("Show")
            self.viewBottomConstraint.constant = -keyboardHeight
            //print(self.viewBottomConstraint.constant)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        UIView.animate(withDuration: 0.3) {
            //print("Hide")
            self.viewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    func loadComments(){
        let postCommentRef = Database.database().reference().child("post-comments").child(self.postID)
        postCommentRef.observe(.childAdded) { (snapshot) in
            Database.database().reference().child("comments").child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshotComment) in
                if let dict = snapshotComment.value as? [String:Any]{
                    let comment = Comment.transformComment(dict: dict)
                    self.fetchUser(uid: comment.uid, completed: {
                        self.comments.append(comment)
                        self.tableView.reloadData()
                    })
                }
            })
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
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let ref = Database.database().reference()
        let commentRef = ref.child("comments")
        let commentID = commentRef.childByAutoId().key
        let itemRef = commentRef.child(commentID!)
        guard let currentUser = Auth.auth().currentUser else{
            print("Identification Wrong")
            return
        }
        let uid = currentUser.uid
        let timeInterval:TimeInterval = NSDate().timeIntervalSince1970
        let timeStamp = String(Int(timeInterval))
        let createdAt = timeStamp
        itemRef.setValue(["uid": uid, "commentText": self.commentTextField.text!, "createdAt": createdAt]) { (error, ref) in
            if error != nil{
                return
            }
            self.emptyTextfield()
            self.view.endEditing(true)
        }
        
        //Create the post-comment mapping table in database
        let postCommentRef = ref.child("post-comments").child(self.postID).child(commentID!)
        postCommentRef.setValue(true) { (error, ref) in
            if error != nil{
                return
            }
        }
        updateNotiComment()
    }
    
    func handleTextField(){
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(){
        if let commentText = commentTextField.text, !commentText.isEmpty{
            sendButton.setTitleColor(UIColor.blue, for: .normal)
            sendButton.isEnabled = true
        } else{
            sendButton.setTitleColor(UIColor.lightGray, for: .normal)
            sendButton.isEnabled = false
        }
       
    }
    
    func emptyTextfield(){
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell {
            let comment = comments[indexPath.row]
            let user = users[indexPath.row]
            cell.comment = comment
            cell.user = user
            return cell
        } else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        commentTextField.becomeFirstResponder()
    }
    
    
    func updateNotiComment() {
        let postCommentRef = Database.database().reference().child("post-comments").child(self.postID)
        //let postCommentRef = Database.database().reference().child("posts").child(post!.postId).key
        let newCId = Database.database().reference().child("post-comments").childByAutoId().key
        let userId = UserUtility.getCurrentUserId()
        let timestamp = currentPost.createdAt
        Database.database().reference().child("feed").child(userId!).child(newCId!).setValue(true)
        postCommentRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot]
            arraySnapshot?.forEach({ (child) in
                FeedUtility.feedRef.child(child.key).updateChildValues(["\(newCId)": true])
                let newNotificationId = ActivityUtility.notificationREF.child(child.key).childByAutoId().key
                let newNotificationRef = ActivityUtility.notificationREF.child(child.key).child(newNotificationId!)
                let notify = ["from": UserUtility.getCurrentUserId()!,
                              "type": "newComment",
                              "objectId": postCommentRef.key,
                              "timeStamp": timestamp
                    ]
                
                newNotificationRef.setValue(notify)
                
                
            })
            
        })
    }
    
}
