//
//  AlertViewUtility.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit

class AlertViewUtility {
    
    class func showWarningView(_ content:String) {
        
        showNoFunctionAlertView("Warning", message: content)
        
    }
    
    class func showNoFunctionAlertView(_ title:String?=nil,message:String) {
        
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
   
        }
        alertController.addAction(OKAction)
        
        ViewControllerUtility.getRootViewController().present(alertController, animated: true) {
            
        }
        
    }
    
    class func showCameraAccessAlertView(){
        
        let alertController = UIAlertController(title: nil, message: "We need you turn on Camera service to access camera.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Setting", style: .default) { (action) in
            
            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        ViewControllerUtility.getRootViewController().present(alertController, animated: true){}
    }
    
    
    class func showPhotoLibraryAccessAlertView(){
        
        let alertController = UIAlertController(title: nil, message: "We need you turn on Photos service to access your photos.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Setting", style: .default) { (action) in
            
            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!);
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        ViewControllerUtility.getRootViewController().present(alertController, animated: true){}
    }
    
    class func showLocationAlertView(){
        
        let alertController = UIAlertController(title: "", message: "We need you turn on GPS service to get current location.", preferredStyle: .alert)
        
        
        let OKAction = UIAlertAction(title: "Setting", style: .default) { (action) in
            
            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        ViewControllerUtility.getRootViewController().present(alertController, animated: true){}
    }
    
    class func showLocationPrivacyAlertView(){
        let alertController = UIAlertController(title: "", message: "We need you turn on GPS service to get current location.", preferredStyle: .alert)
        
        
        let OKAction = UIAlertAction(title: "Setting", style: .default) { (action) in
            
            let url = URL(string: "App-Prefs:root=Privacy")!
            UIApplication.shared.openURL(url)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        ViewControllerUtility.getRootViewController().present(alertController, animated: true){}
    }


}
