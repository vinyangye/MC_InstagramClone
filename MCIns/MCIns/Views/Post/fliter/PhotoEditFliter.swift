//
//  PhotoEditFliter.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import CoreImage

class PhotoEditFliter: PhotoBrightness, PhotoContrast, PhotoSaturation {
    
    // MARK: - Properties
    
    let filter = CIFilter(name: "CIColorControls")!
}
