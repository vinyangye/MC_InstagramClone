//
//  PublicUtility.swift
//  MCIns
//
//  Created by ye yang on 16/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import MBProgressHUD

class PublicUtility {
    
    class func showDefaultHUDView(){
        
        hideHUDView()
        
        let loading = MBProgressHUD.showAdded(to: ViewControllerUtility.getRootViewController().view, animated: true)
        loading.isUserInteractionEnabled = false
//        loading.mode = MBProgressHUDMode.determinateHorizontalBar
        loading.label.text = "Please Wait ..."
        
    }
    
    
    class func hideHUDView() {
        MBProgressHUD.hide(for: ViewControllerUtility.getRootViewController().view, animated: true)

    }
    
    class func setupTime(timestamp: String) -> String{
        
        var descriptionText: String = ""
        let postTimeInterval = TimeInterval(timestamp)
        let postTime = Date(timeIntervalSince1970: postTimeInterval!)
        let currentTime = Date(timeIntervalSinceNow: 0)
        let timeInterval = currentTime - postTime
        let intTimeInterval = Int(timeInterval)
        let day = intTimeInterval/86400 >= 1 ? String((intTimeInterval / 86400)) + " days" : ""
        let hour = (intTimeInterval % 86400) / 3600 >= 1 ? String((intTimeInterval % 86400) / 3600) + " hours" : ""
        let minute = (intTimeInterval % 3600) / 60 >= 1 ? String((intTimeInterval % 3600) / 60) + " minutes" : ""
        
        if day != ""{
            descriptionText = day + " ago"
        }else if hour != ""{
            descriptionText = hour + " ago"
        }else if minute != ""{
            descriptionText = minute + " ago"
        }else{
            descriptionText = "Just now"
        }
        
        return descriptionText
    }
    
}
