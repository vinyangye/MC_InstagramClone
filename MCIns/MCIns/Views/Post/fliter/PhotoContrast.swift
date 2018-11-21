//
//  PhotoContrast.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import CoreImage

protocol PhotoContrast: Processable {
    var minContrastValue: Float { get }
    var maxContrastValue: Float { get }
    var currentContrastValue: Float { get }
    func contrast(_ contrast: Float)
}

extension PhotoContrast {
    
    var minContrastValue: Float {
        return 0.00
    }
    
    var maxContrastValue: Float {
        return 4.00
    }
    
    var currentContrastValue: Float {
        return filter.value(forKey: kCIInputContrastKey) as? Float ?? 1.00
    }
    
    func contrast(_ contrast: Float) {
        self.filter.setValue(contrast, forKey: kCIInputContrastKey)
    }
}
