//
//  PhotoSaturation.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import CoreImage

protocol PhotoSaturation: Processable {
    var minSaturationValue: Float { get }
    var maxSaturationValue: Float { get }
    var currentSaturationValue: Float { get }
    func saturation(_ saturation: Float)
}

extension PhotoSaturation {
    
    var minSaturationValue: Float {
        return 0.00
    }
    
    var maxSaturationValue: Float {
        return 2.00
    }
    
    var currentSaturationValue: Float {
        return filter.value(forKey: kCIInputSaturationKey) as? Float ?? 1.00
    }
    
    func saturation(_ saturation: Float) {
        self.filter.setValue(saturation, forKey: kCIInputSaturationKey)
    }
}
