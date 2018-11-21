//
//  BaseTabBarController.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    var firstTime = true
    var postButton: UIButton!
    var selectedImages = [UIImage]()
    var selectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        setupInfo()
        
        perform(#selector(finishLoading), with: self, afterDelay: 1.5) //give some time for loading
        
    }
    
    func setupInfo() {
        UserUtility.initCurrentUser()
        UserUtility.initAllUser()
//        ActivityUtility.loadActivity()
        PostUtility.initAllPost()

    }
    
    func setupPostButton() {
        let selfBar = self.tabBar as! CustomTabBar
        postButton = selfBar.addButton
        postButton.addTarget(self, action: #selector(self.postBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func finishLoading() {
        self.tabBar.isHidden = false
        setupPostButton()
    }
    
    @objc func postBtnTapped(_ sender: UIButton) {
        PostUtility.choosePostPhoto(vc: self) { (resultStatus, images) in
            switch resultStatus{
            case .cameraDenied:
                AlertViewUtility.showCameraAccessAlertView()
                break
            case .libraryDenied:
                AlertViewUtility.showPhotoLibraryAccessAlertView()
                break
            case .canceled:
                break
            case .success:
                break
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

