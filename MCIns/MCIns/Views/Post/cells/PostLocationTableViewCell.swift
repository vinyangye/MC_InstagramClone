//
//  PostLocationTableViewCell.swift
//  MCIns
//
//  Created by ye yang on 19/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class PostLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationIconImage: UIImageView!{
        didSet{
            locationIconImage.image = #imageLiteral(resourceName: "icon_event_location")
        }
    }
    @IBOutlet weak var primaryLocationLabel: UILabel!{
        didSet{
            primaryLocationLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        }
    }
    
    @IBOutlet weak var emptyLocationLabel: UILabel!{
        didSet{
//            emptyLocationLabel.textColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
            emptyLocationLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        }
    }
    
    @IBOutlet weak var secondLocationLabel: UILabel!{
        didSet{
            secondLocationLabel.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        }
    }
    
    var location: PostLocation?
    
    func updateView() {
        if location == nil{
            emptyLocationLabel.text = "Add a Location"
            primaryLocationLabel.isHidden = true
            secondLocationLabel.isHidden = true
            emptyLocationLabel.isHidden = false
        }else{
            if location?.address == ""{
                emptyLocationLabel.text = location?.name
                primaryLocationLabel.isHidden = true
                secondLocationLabel.isHidden = true
                emptyLocationLabel.isHidden = false
            }else{
                emptyLocationLabel.isHidden = true
                primaryLocationLabel.isHidden = false
                secondLocationLabel.isHidden = false
                primaryLocationLabel.text = location?.name
                secondLocationLabel.text = location?.address
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
