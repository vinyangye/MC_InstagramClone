//
//  ProfileCollectionViewCell.swift
//  MCIns
//
//  Created by PaddyChang on 28/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var post: Post? {
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        if let photoRefString = post?.photoRef {
            let photoUrl = URL(string: photoRefString)
            imageView.sd_setImage(with: photoUrl)
        }
    }
}
