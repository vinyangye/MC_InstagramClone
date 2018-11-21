//
//  PhotoBrightness.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import CoreImage

protocol PhotoBrightness: Processable {
    var minBrightnessValue: Float { get }
    var maxBrightnessValue: Float { get }
    var currentBrightnessValue: Float { get }
    func brightness(_ brightness: Float)
}

extension PhotoBrightness {
    
    var minBrightnessValue: Float {
        return -1.00
    }
    
    var maxBrightnessValue: Float {
        return 1.00
    }
    
    var currentBrightnessValue: Float {
        return filter.value(forKey: kCIInputBrightnessKey) as? Float ?? 0.00
    }
    
    func brightness(_ brightness: Float) {
        self.filter.setValue(brightness, forKey: kCIInputBrightnessKey)
    }
}

