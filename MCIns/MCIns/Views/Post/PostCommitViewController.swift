//
//  PostCommitViewController.swift
//  MCIns
//
//  Created by ye yang on 16/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import JXPhotoBrowser
import GooglePlaces

class PostCommitViewController: UIViewController {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    
    var post: Post?
    var location: PostLocation?
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        setupNavigationBar()
        
    }
    
    
    
    func setupBasicUI() {
        maskView.isHidden = true
        
        textView.delegate = self
        
        tableView.backgroundColor = UIColor.white
        photoImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        photoImage.addGestureRecognizer(tap)
        //        self.photoImage.image = selectedImage
        if post?.photos.count == 0 {
            self.post?.photos[0] = #imageLiteral(resourceName: "placeholder-photo")
            self.photoImage.image = #imageLiteral(resourceName: "placeholder-photo")
        }else{
            self.photoImage.image = post?.photos[0]
        }
        textView.text = post?.caption
        if textView.text != ""{
            placeHolderLabel.isHidden = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib.init(nibName: "PostLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "PostLocationTableViewCell")
    }
    
    
    
    func setupNavigationBar() {
        
        let shareBtn = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareButtonTapped(_:)))
        shareBtn.tintColor = #colorLiteral(red: 0.2078431373, green: 0.462745098, blue: 0.9607843137, alpha: 1)
        navigationItem.rightBarButtonItem = shareBtn

    }
    
    //show image browser
    @objc func imageTapped() {
        
        PhotoBrowser.show(localImages: (self.post?.photos)!, originPageIndex: 0)
    }
    
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        self.post?.caption = self.textView.text
        PostUtility.sharePost { (error) in
            if error != nil {
                print(error!.localizedDescription)
                AlertViewUtility.showWarningView(error!.localizedDescription)
                return
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

}

extension PostCommitViewController: UITextViewDelegate{
    
    // placeholder for textView
    func textViewDidBeginEditing(_ textView: UITextView) {

        self.placeHolderLabel.isHidden = true
        self.maskView.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.textView.text==nil || self.textView.text == ""{
            
            self.placeHolderLabel.isHidden = false
            
        }else{
            self.post?.caption = self.textView.text
            self.placeHolderLabel.isHidden = true
        }
        
        self.maskView.isHidden = true
    }
}

extension PostCommitViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostLocationTableViewCell", for: indexPath) as! PostLocationTableViewCell
        cell.location = self.location
        cell.updateView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostSearchLocationViewController") as! PostSearchLocationViewController
        vc.locationUpdateDelegate = self
        vc.searchbarText = self.searchText
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension PostCommitViewController: locationUpdateDelegate{
    func updateLocationInfo(place: PostLocation, searchText: String) {
        self.searchText = searchText
        self.location = place
        self.post?.locationName = place.name
        self.post?.locationAddress = place.address
        self.post?.locationLongitude = place.longitude
        self.post?.locationLatitude = place.latitude
        tableView.reloadData()
    }
    
    
}
