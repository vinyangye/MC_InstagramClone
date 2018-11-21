//
//  ProfileEditTableViewController.swift
//  MCIns
//
//  Created by PaddyChang on 28/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import FirebaseAuth

protocol ProfileEditTableViewControllerDelegate {
    func updateUserInfo()
}

class ProfileEditTableViewController: UITableViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var Delegate: ProfileEditTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        navigationItem.backBarButtonItem?.title = "Back"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        updateView()
    }
    
    func updateView(){
        let userId = UserUtility.getCurrentUserId()
        let userRef = Database.database().reference()
        userRef.child("users").child(userId!).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            self.usernameTextField.text = value["username"] as? String ?? ""
            self.editImageView.sd_setImage(with: URL(string: value["profileImageUrl"] as? String ?? ""))
            self.emailTextField.text = value["email"] as? String ?? ""
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    @IBAction func saveBtn(_ sender: Any) {
        let userId = UserUtility.getCurrentUserId()
        if let editImage = self.editImageView.image, let imageData = UIImageJPEGRepresentation(editImage, 0.1){
            PublicUtility.showDefaultHUDView()
            UserUtility.updateUserInfo(userId: userId!, email: self.emailTextField.text!, username: self.usernameTextField.text!, imageData: imageData) { (err, user) in
                PublicUtility.hideHUDView()
                if err != nil{
                    
                    AlertViewUtility.showWarningView(err!.localizedDescription)
                    return
                }else{
                    AlertViewUtility.showNoFunctionAlertView(message: "Success")
                    self.Delegate?.updateUserInfo()
                }
            }
        }
    }
    
    @IBAction func changeProfilePhoto_touch(_ sender: Any) {
        let pickerContorller = UIImagePickerController()
        pickerContorller.delegate = self
        present(pickerContorller, animated: true, completion: nil)
    }
    
    @IBAction func logOut_touch(_ sender: Any) {
        UserUtility.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ProfileEditTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            editImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileEditTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
