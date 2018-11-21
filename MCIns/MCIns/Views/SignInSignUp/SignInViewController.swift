//
//  SignInViewController.swift
//  MCIns
//
//  Created by ye yang on 14/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

//    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var cutoffline: UIView!
    @IBOutlet weak var cutofflineBottomCons: NSLayoutConstraint!
    
    private var usernameHasValue = false
    private var passwordHasValue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //set up signinView UI
    func setupBasicUI() {
        navigationController?.navigationBar.isHidden = true
        
        usernameField.placeholder = "Email"
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        usernameField.borderStyle = UITextBorderStyle.roundedRect
        passwordField.borderStyle = UITextBorderStyle.roundedRect
        usernameField.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        passwordField.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        usernameField.clearButtonMode = UITextFieldViewMode.whileEditing
        passwordField.clearButtonMode = UITextFieldViewMode.whileEditing
        usernameField.addTarget(self, action: #selector(usernametextFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(passwordtextFieldDidChange(_:)),
                                for: UIControlEvents.editingChanged)
        usernameField.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        passwordField.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        
        loginBtn.setTitle("Log In", for: .normal)
        loginBtn.backgroundColor = #colorLiteral(red: 0.6470588235, green: 0.7921568627, blue: 0.9529411765, alpha: 1)
        loginBtn.isEnabled = false
        loginBtn.setTitleColor(UIColor.white, for: .normal)
        loginBtn.layer.cornerRadius = 5
//        loginBtn.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
//        loginBtn.layer.shadowOpacity = 0.2
        loginBtn.addTarget(self, action: #selector(self.signIn(_:)), for: UIControlEvents.touchUpInside)
        
        noticeLabel.text = "Don't have an account? "
        noticeLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        signupBtn.setTitle("Sign Up", for: .normal)
        signupBtn.addTarget(self, action: #selector(self.toSignUpViewController(_:)), for: UIControlEvents.touchUpInside)
        
        cutoffline.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cutoffline.layer.shadowOpacity = 0.1
        
        
    }
    
    // tap view hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    @objc func usernametextFieldDidChange(_ textField: UITextField) {
        if usernameField.text != nil && usernameField.text?.count != 0{
            usernameHasValue = true
        }else{
             usernameHasValue = false
        }
        loginBtnChange()
    }

    @objc func passwordtextFieldDidChange(_ textField: UITextField) {
        if passwordField.text != nil && passwordField.text?.count != 0{
            passwordHasValue = true
        }else{
            passwordHasValue = false
        }
        loginBtnChange()
    }
    
    func loginBtnChange() {
        if usernameHasValue && passwordHasValue{
            self.loginBtn.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
            self.loginBtn.isEnabled = true
        }else{
            self.loginBtn.backgroundColor = #colorLiteral(red: 0.6470588235, green: 0.7921568627, blue: 0.9529411765, alpha: 1)
            self.loginBtn.isEnabled = false
        }
    }
    
    @objc func signIn(_ sender: UIButton) {
        self.view.endEditing(false)
        PublicUtility.showDefaultHUDView()
        UserUtility.signIn(email: usernameField.text!, password: passwordField.text!) { (error, user) in
            PublicUtility.hideHUDView()
            if error != nil{
                print(error!.localizedDescription)
                AlertViewUtility.showWarningView(error!.localizedDescription)
                return
            }else{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseTabBarController") as! BaseTabBarController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    @objc func toSignUpViewController(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Sign", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        //self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
 

}
