//
//  CommentTableViewCell.swift
//  MCIns
//
//  Created by Charles Huang on 1/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var comment: Comment?{
        didSet{
            setupCommentInfo()
        }
    }
    
    var user: InsUser?{
        didSet{
            setupUserInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tapGesture_userImg = UITapGestureRecognizer(target: self, action: #selector(self.userImageView_TouchUpInside))
        self.userImage.addGestureRecognizer(tapGesture_userImg)
        self.userImage.isUserInteractionEnabled = true
    }
    
    @objc func userImageView_TouchUpInside(){
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
        vc.user = self.user
        ViewControllerUtility.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(userImage: String, userLabel: String, commentLabel: String) {
        self.userImage.image = UIImage(named: userImage)
        self.userImage.setRounded()
        self.userLabel.text = userLabel
        self.commentLabel.text = commentLabel
    }
    
    func setupCommentInfo(){
        commentLabel.text = comment?.commentText
    }
    
    func setupUserInfo(){
        userLabel.text = user?.username
        if let imageUrlString = user?.profileImageUrl{
            let imageUrl = URL(string: imageUrlString)
            self.userImage.sd_setImage(with: imageUrl)
            self.userImage.setRounded()
        }
    }
    
}
