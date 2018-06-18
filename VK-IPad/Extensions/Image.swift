//
//  Image.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

extension UIImage {
    func cropImage(cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        
        let inputImage = self
        
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        guard let cutImageRef = inputImage.cgImage?.cropping(to:cropZone) else { return nil }
        
        return UIImage(cgImage: cutImageRef)
    }
    
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
