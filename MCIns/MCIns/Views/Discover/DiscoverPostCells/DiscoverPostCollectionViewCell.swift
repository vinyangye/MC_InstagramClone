//
//  DiscoverPostCollectionViewCell.swift
//  MCIns
//
//  Created by ye yang on 18/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import SDWebImage

class DiscoverPostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
    
    var post: Post? {
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        if let photoRefString = post?.photoRef{
            let photoUrl = URL(string: photoRefString)
            self.postImage.sd_setImage(with: photoUrl)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

