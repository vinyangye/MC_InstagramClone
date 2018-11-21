//
//  PhotoEditViewController.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import Stevia

class PhotoEditViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightnessUISlider: UISlider!
    @IBOutlet weak var contrastUISlider: UISlider!
    @IBOutlet weak var saturationUISlider: UISlider!
    
    var post: Post?
    var editor = PhotoEditFliter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBasic()
    }
    
    func setupBasic() {
        imageView.image = post?.photos[0]
        imageView.contentMode = .scaleAspectFit
        editor.input((post?.photos[0])!)
        setFliterValue()
    }
    func setupNavigationBar() {
        navigationItem.title = "Edit"
        let shareBtn = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextButtonTapped(_:)))
        shareBtn.tintColor = #colorLiteral(red: 0.2078431373, green: 0.462745098, blue: 0.9607843137, alpha: 1)
        navigationItem.rightBarButtonItem = shareBtn
        
    }
    
    @objc func nextButtonTapped(_ sender: UIBarButtonItem) {
        let postVC = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostCommitViewController") as! PostCommitViewController
        var photos = [UIImage]()
        photos.append(self.imageView.image!)
        post!.photos = photos
        postVC.post = post
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    func setFliterValue() {
        contrastUISlider.value = editor.currentContrastValue
        contrastUISlider.maximumValue = editor.maxContrastValue
        contrastUISlider.minimumValue = editor.minContrastValue
        
        brightnessUISlider.value = editor.currentBrightnessValue
        brightnessUISlider.maximumValue = editor.maxBrightnessValue
        brightnessUISlider.minimumValue = editor.minBrightnessValue
        
        saturationUISlider.value = editor.currentSaturationValue
        saturationUISlider.maximumValue = editor.maxSaturationValue
        saturationUISlider.minimumValue = editor.minSaturationValue
    }
    
    @IBAction func brightnessUISliderPressed(_ sender: UISlider) {
        DispatchQueue.main.async {
            
            self.editor.brightness(sender.value)
            self.imageView.image = self.editor.outputUIImage()
        }
    }
    
    @IBAction func contrastUISliderPressed(_ sender: UISlider) {
        DispatchQueue.main.async {
            
            self.editor.contrast(sender.value)
            self.imageView.image = self.editor.outputUIImage()
        }
    }
    
    @IBAction func saturationUISliderPressed(_ sender: UISlider) {
        DispatchQueue.main.async {

            self.editor.saturation(sender.value)
            self.imageView.image = self.editor.outputUIImage()
        }
    }
    

   

}


