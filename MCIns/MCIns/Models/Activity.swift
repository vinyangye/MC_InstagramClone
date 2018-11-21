//
//  Notification.swift
//  MCIns
//
//  Created by Zhao on 2018/10/12.
//  Copyright © 2018年 MCgroup. All rights reserved.
//

import Foundation
import FirebaseAuth
class Activity {
    var from:String?
    var objectID:String?
    var type:String?
    var timestamp:String?
    var id:String?
}

extension Activity {
    static func activity(dict: [String: Any], key:String) -> Activity {
        let notification = Activity()
        notification.from = dict["from"] as? String
        notification.id = key
        notification.objectID = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timeStamp"] as? String
        
        return notification
    }
    
    static func activity(dict: [String: Any]) -> Activity{
        let notification = Activity()
        notification.from = dict["from"] as? String
        //notification.id = key
        notification.objectID = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timeStamp"] as? String
        return notification
    }
}
