//
//  NavigationControllerExtension.swift
//  MCIns
//
//  Created by ye yang on 16/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    
    func popToViewController(_ className:AnyClass) -> Bool {
        
        let allViewController: [UIViewController] = self.viewControllers as [UIViewController]
        
        for aviewcontroller : UIViewController in allViewController
        {
            if aviewcontroller.isKind(of: className)
            {
                self.popToViewController(aviewcontroller, animated: true)
                return true
            }
        }
        return false

    }
    
    //use navigation controller push and hide the tab bar
    func pushViewControllerAndHideBottomBar(_ vc: UIViewController, animated: Bool){
        
        vc.hidesBottomBarWhenPushed = true
        pushViewController(vc, animated: true)
        
    }
    
    
    
}
