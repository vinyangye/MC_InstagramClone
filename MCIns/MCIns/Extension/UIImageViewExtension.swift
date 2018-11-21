//
//  UIImageViewExtension.swift
//  MCIns
//
//  Created by Charles Huang on 1/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
