//
//  CustomTabBar.swift
//  MCIns
//
//  Created by ye yang on 17/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBar {
    
    private var firstTime = true
    var addButton: UIButton = {
        
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "Post"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "Photo_selected"), for: .selected)
        btn.setImage(#imageLiteral(resourceName: "Photo_selected"), for: .highlighted)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    override func layoutSubviews() {
        if !firstTime{
            return
        }
        super.layoutSubviews()
        
        let btnWidth = self.bounds.width/5
        let btnHeight:CGFloat = UITabBarController().tabBar.frame.height
        var i = 0
        
        for button in self.subviews{
            if button.isKind(of: NSClassFromString("UITabBarButton")!){
                if i == 2{
                    i = 3
                }
                button.frame = CGRect(x: btnWidth * CGFloat(i), y: 0, width: btnWidth, height: btnHeight)
                i += 1
            }
        }
        self.addButton.frame = CGRect(x: btnWidth * 2 + btnWidth/2 - btnHeight/3+2, y: 1/2*btnHeight-btnHeight/3+3, width: btnHeight/2, height: btnHeight/2)
        self.addSubview(self.addButton)
        firstTime = false
    }
    
    
}
