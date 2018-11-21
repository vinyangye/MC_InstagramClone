//
//  ViewControllerUtility.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerUtility {
    
    static var activityIndicator = UIActivityIndicatorView()
    
    class func getCurrentViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return getCurrentViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getCurrentViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return getCurrentViewController(controller: presented)
        }
        return controller
    }
    
    class func getRootViewController() -> UIViewController {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController

        }
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.window!.rootViewController!
        
    }
    
    //show the loading view
    class func showActivityIndicator(viewController: UIViewController) {
        
        activityIndicator.center = viewController.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        viewController.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    //stop loading view
    class func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
