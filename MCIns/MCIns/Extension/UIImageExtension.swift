//
//  UIImageExtension.swift
//  MCIns
//
//  Created by ye yang on 17/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    
    func imageByRemoveBlackBg() -> UIImage? {
        let colorMasking: [CGFloat] = [0, 32, 0, 32, 0, 32]
        return transparentColor(colorMasking: colorMasking)
    }
    
    
    public func grayImage(sourceImage : UIImage) -> UIImage{
        let imageSize = sourceImage.size
        let width = Int(imageSize.width)
        let height = Int(imageSize.height)
        let spaceRef = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: spaceRef, bitmapInfo: CGBitmapInfo().rawValue)!
        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)

        context.draw(sourceImage.cgImage!, in: rect)

        let grayImage = UIImage(cgImage: context.makeImage()!)
        
        return grayImage

    }
    
    func transparentColor(colorMasking:[CGFloat]) -> UIImage? {
        if let rawImageRef = self.cgImage {
            UIGraphicsBeginImageContext(self.size)
            if let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) {
                let context: CGContext = UIGraphicsGetCurrentContext()!
                context.translateBy(x: 0.0, y: self.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.draw(maskedImageRef, in: CGRect(x:0, y:0, width:self.size.width,
                                                        height:self.size.height))
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return result
            }
        }
        return nil
    }
    
}

