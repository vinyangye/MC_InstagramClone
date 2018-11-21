//
//  PhotoUtility.swift
//  MCIns
//
//  Created by ye yang on 17/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit
import YPImagePicker
import AVFoundation
import AssetsLibrary
import Photos

public enum photoProcessStatus {
    case cameraDenied
    case libraryDenied
    case canceled
    case success
    
}

class PhotoUtility {
    
    
    
    //upload profile photo
    class func chooseProfilePhoto(vc: UIViewController, _ callback:@escaping (photoProcessStatus,UIImage?)->Void) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraButton = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            func setupTakePhotoVC(){
                var config = YPImagePickerConfiguration()
                config.screens = [.photo]
                config.library.mediaType = .photo
                config.showsFilters = false
                let grid = GridView()
                config.overlayView = grid
                config.hidesStatusBar = true
                let picker = YPImagePicker(configuration: config)
                picker.didFinishPicking { [unowned picker] items, _ in
                    if let photo = items.singlePhoto {
                        callback(.success, photo.image)
                    }
                    picker.dismiss(animated: true, completion: nil)
                }
                vc.present(picker, animated: true, completion: nil)
            }
            switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .denied:
                AlertViewUtility.showCameraAccessAlertView()
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
                    // User clicked ok
                    if (videoGranted) {
                        setupTakePhotoVC()
                        // User clicked don't allow
                    } else {
                        callback(.cameraDenied,nil)
                    }
                })
                break
            default:
                setupTakePhotoVC()
            }
            
        })
        let libraryButton = UIAlertAction(title: "Choose From Photos", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            func setupPhotoLibraryVC(){
                var config = YPImagePickerConfiguration()
                config.screens = [.library]
                config.library.mediaType = .photo
                config.showsFilters = false
                let picker = YPImagePicker(configuration: config)
                picker.didFinishPicking { [unowned picker] items, _ in
                    if let photo = items.singlePhoto {
                        callback(.success, photo.image)
                    }
                    picker.dismiss(animated: true, completion: nil)
                }
                vc.present(picker, animated: true, completion: nil)
            }
            
            //check the user permission of accessing photo library
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status{
            case .denied:
                AlertViewUtility.showPhotoLibraryAccessAlertView()
                break
            case .notDetermined:
                
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    DispatchQueue.main.async {
                        if (newStatus == .authorized) {
                            setupPhotoLibraryVC()
                        }
                        else {
                            callback(.libraryDenied, nil)
                        }
                    }
                })
                break
            default:
                setupPhotoLibraryVC()
                break
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            callback(.canceled, nil)
        })
        
        optionMenu.addAction(cameraButton)
        optionMenu.addAction(libraryButton)
        optionMenu.addAction(cancelAction)
        
        vc.present(optionMenu, animated: true, completion: nil)
    }
    
 
    
}
