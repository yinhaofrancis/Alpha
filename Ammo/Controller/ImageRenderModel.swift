//
//  ImageFilter.swift
//  Ammo
//
//  Created by wenyang on 2022/10/8.
//

import CoreImage
import UIKit

public protocol ImageRenderModel{
    func filter(img:CIImage?,bound:CGRect)->CIImage?
}

public class DisplayModeFilter:ImageRenderModel{
    
    public enum DisplayMode:Int{
        case scaleToFill = 0
        case scaleAspectFit = 1
        case scaleAspectFill = 2
    }
    public init() {}
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let i = img else { return img }
        guard let image = self.filter(img: i, mode: self.displayMode, bound: bound) else { return img }
        
        return image
    }
    
    private var transformFilter:CIFilter? = CIFilter(name: "CIAffineTransform");

    private func transformImage(img:CIImage,transform:CGAffineTransform)->CIImage?{
        self.transformFilter?.setDefaults()
        self.transformFilter?.setValue(transform, forKey: "inputTransform")
        self.transformFilter?.setValue(img, forKey: kCIInputImageKey)
        return self.transformFilter?.outputImage
    }
    
    private func filter(img:CIImage,mode:DisplayMode,bound:CGRect)->CIImage?{
        
        var scale:CGFloat = 1;
        if mode == .scaleAspectFill{
            scale = max(bound.width / img.extent.width, bound.height / img.extent.height)
            let scaleTransFor = CGAffineTransform(scaleX: scale, y: scale)
            
            let endFrame = img.extent.applying(scaleTransFor)
            let deltax = (bound.width - endFrame.width) / 2
            let deltay = (bound.height - endFrame.height) / 2
            return self.transformImage(img: img, transform:  CGAffineTransform(translationX: deltax, y: deltay).scaledBy(x: scale, y: scale))
        }else if mode == .scaleAspectFit{
            scale = min(bound.width / img.extent.width, bound.height / img.extent.height)
            let scaleTransFor = CGAffineTransform(scaleX: scale, y: scale)
            
            let endFrame = img.extent.applying(scaleTransFor)
            let deltax = (bound.width - endFrame.width) / 2
            let deltay = (bound.height - endFrame.height) / 2
            return self.transformImage(img: img, transform:  CGAffineTransform(translationX: deltax, y: deltay).scaledBy(x: scale, y: scale))
        }else{
            let x = bound.width / img.extent.width
            let y = bound.height / img.extent.height
            return self.transformImage(img: img, transform: CGAffineTransform(scaleX: x, y: y))
        }
    }
    public var displayMode:DisplayMode = .scaleAspectFit
}
