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
    
    private var transformFilter = ImageAffineTransform()
    private var crop = ImageCrop()
    private var imageblend = ImageSourceOver()

    private func transformImage(img:CIImage,transform:CGAffineTransform)->CIImage?{
        return self.transformFilter.filter(transform: transform, image: img)
    }
    private func blend(image:CIImage?,bg:CIImage?)->CIImage?{
        self.imageblend.filter(image: image, imageBackground: bg)
    }
    private func makeBackground(bound:CGRect)->CIImage?{
  
        return self.crop.filter(rectangle: CIVector(cgRect: CGRect(x: 0, y: 0, width: bound.width, height: bound.height)), image: CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0)))
    }
    private func filter(img:CIImage,mode:DisplayMode,bound:CGRect)->CIImage?{
        
        var result:CIImage?
        var scale:CGFloat = 1;
        if mode == .scaleAspectFill{
            scale = max(bound.width / img.extent.width, bound.height / img.extent.height)
            let scaleTransFor = CGAffineTransform(scaleX: scale, y: scale)
            
            let endFrame = img.extent.applying(scaleTransFor)
            let deltax = (bound.width - endFrame.width) / 2 - endFrame.minX
            let deltay = (bound.height - endFrame.height) / 2 - endFrame.minY
            result = self.transformImage(img: img, transform:  CGAffineTransform(translationX: deltax, y: deltay).scaledBy(x: scale, y: scale))
        }else if mode == .scaleAspectFit{
            scale = min(bound.width / img.extent.width, bound.height / img.extent.height)
            let scaleTransFor = CGAffineTransform(scaleX: scale, y: scale)
            
            let endFrame = img.extent.applying(scaleTransFor)
            let deltax = (bound.width - endFrame.width) / 2 - endFrame.minX
            let deltay = (bound.height - endFrame.height) / 2 - endFrame.minY
            result = self.transformImage(img: img, transform:  CGAffineTransform(translationX: deltax, y: deltay).scaledBy(x: scale, y: scale))
        }else{
            let x = bound.width / img.extent.width
            let y = bound.height / img.extent.height
            result = self.transformImage(img: img, transform: CGAffineTransform(scaleX: x, y: y))
        }
//        let back = self.makeBackground(bound: bound)
//        result = self.blend(image: result, bg: back)
        return result
        
    }
    public var displayMode:DisplayMode = .scaleAspectFit
}
