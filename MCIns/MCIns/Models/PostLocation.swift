//
//  PostLocation.swift
//  MCIns
//
//  Created by ye yang on 20/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation

class PostLocation{
    var name: String = ""
    var address: String = ""
    var longitude: String = ""
    var latitude: String = ""
}

extension PostLocation {
    static func setupLocation(name: String,address: String,longitude: String,latitude: String) -> PostLocation{
        let location = PostLocation()
        location.name = name
        location.address = address
        location.longitude = longitude
        location.latitude = latitude
        return location
    }

}

