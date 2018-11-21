//
//  SignUpViewController.swift
//  MCIns
//
//  Created by ye yang on 14/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var cutofflineBottomCons: NSLayoutConstraint!
    @IBOutlet weak var userImageTopCons: NSLayoutConstraint!
    @IBOutlet weak var textFieldTopCons: NSLayoutConstraint!
    @IBOutlet weak var cutoffline: UIView!
    
    private var emailHasValue = false
    private var usernameHasValue = false
    private var passwordHasValue = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    // update top constraint when keyboard appear
    @objc func keyboardShow(note: Notification)  {
        let kbInfo = note.userInfo
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double
        self.userImageTopCons.constant = 10
        self.textFieldTopCons.constant = 8
        //use animate to smooth the view change
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardHidden(note: Notification){
        let kbInfo = note.userInfo
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double
        self.userImageTopCons.constant = 100
        self.textFieldTopCons.constant = 20
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func setupBasicUI() {
        navigationController?.navigationBar.isHidden = true
        
        userImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.userImageTapped))
        userImage.addGestureRecognizer(tap)
        userImage.contentMode = .scaleAspectFill
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        userImage.layer.shadowOpacity = 0.1
        
        emailField.placeholder = "Email"
        usernameField.placeholder = "Username"
        passwordField.placeholder = "Password"
        
        passwordField.isSecureTextEntry = true
        emailField.borderStyle = UITextBorderStyle.roundedRect
        usernameField.borderStyle = UITextBorderStyle.roundedRect
        passwordField.borderStyle = UITextBorderStyle.roundedRect
        emailField.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        usernameField.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        passwordField.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        emailField.clearButtonMode = UITextFieldViewMode.whileEditing
        usernameField.clearButtonMode = UITextFieldViewMode.whileEditing
        passwordField.clearButtonMode = UITextFieldViewMode.whileEditing
        emailField.addTarget(self, action: #selector(emailtextFieldDidChange(_:)),
                             for: UIControlEvents.editingChanged)
        usernameField.addTarget(self, action: #selector(usernametextFieldDidChange(_:)),
                                for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(passwordtextFieldDidChange(_:)),
                                for: UIControlEvents.editingChanged)
        emailField.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        usernameField.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        passwordField.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.backgroundColor = #colorLiteral(red: 0.6470588235, green: 0.7921568627, blue: 0.9529411765, alpha: 1)
        signUpBtn.setTitleColor(UIColor.white, for: .normal)
        signUpBtn.layer.cornerRadius = 5
        signUpBtn.isEnabled = false
        signUpBtn.addTarget(self, action: #selector(self.signUPAccount(_:)), for: UIControlEvents.touchUpInside)
        
        noticeLabel.text = "Already have an account? "
        noticeLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        signInBtn.setTitle("Sign In", for: .normal)
        signInBtn.addTarget(self, action: #selector(self.toSignInViewController(_:)), for: UIControlEvents.touchUpInside)
        
        cutoffline.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cutoffline.layer.shadowOpacity = 0.1
        
    }
    
    //present the image picker vc
    @objc func userImageTapped() {
        userImage.backgroundColor = UIColor.gray
        
        //show image picker view & evulate the result
        PhotoUtility.chooseProfilePhoto(vc: self) { (resultStatus, image) in
            switch resultStatus{
            case .cameraDenied:
                AlertViewUtility.showCameraAccessAlertView()
                break
            case .libraryDenied:
                AlertViewUtility.showPhotoLibraryAccessAlertView()
                break
            case .canceled:
                self.userImage.backgroundColor = UIColor.white
                break
            case .success:
                self.selectedImage = image
                self.userImage.image = image
                UserUtility.profilePhoto = image
                break
            }
        }
    }
    
    //tap view hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    
    @objc func toSignInViewController(_ sender: UIButton) {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func emailtextFieldDidChange(_ textField: UITextField) {
        if emailField.text != nil && emailField.text?.count != 0{
            emailHasValue = true
        }else{
            emailHasValue = false
        }
        signUpBtnChange()
    }
    
    @objc func usernametextFieldDidChange(_ textField: UITextField) {
        if usernameField.text != nil && usernameField.text?.count != 0{
            usernameHasValue = true
        }else{
            usernameHasValue = false
        }
        signUpBtnChange()
    }
    
    @objc func passwordtextFieldDidChange(_ textField: UITextField) {
        if passwordField.text != nil && passwordField.text?.count != 0{
            passwordHasValue = true
        }else{
            passwordHasValue = false
        }
        signUpBtnChange()
    }
    
    func signUpBtnChange() {
        if emailHasValue && usernameHasValue && passwordHasValue{
            self.signUpBtn.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
            self.signUpBtn.isEnabled = true
        }else{
            self.signUpBtn.backgroundColor = #colorLiteral(red: 0.6470588235, green: 0.7921568627, blue: 0.9529411765, alpha: 1)
            self.signUpBtn.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userImage.backgroundColor = UIColor.clear
    }
    
    
    //sign up
    @objc func signUPAccount(_ sender: UIButton) {
        self.view.endEditing(false)
        PublicUtility.showDefaultHUDView()
        UserUtility.signUp(email: emailField.text!, username: usernameField.text!, password: passwordField.text!) { (error, user) in
            PublicUtility.hideHUDView()
            if error != nil{
                print(error!.localizedDescription)
                AlertViewUtility.showWarningView(error!.localizedDescription)
                return
            }else{
//                PublicUtility.
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseTabBarController") as! BaseTabBarController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
