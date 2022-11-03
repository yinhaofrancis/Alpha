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

public class ImageDisplayMode:ImageRenderModel{
    
    
    public init() {}
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let i = img else { return img }
        guard let image = self.filter(img: i, mode: self.displayMode, bound: bound) else { return img }
        
        return image
    }
    private var fillModel = ImageFillMode()
    private var transform = ImageAffine(type: .Transform)
    private func filter(img:CIImage,mode:ImageFillMode.DisplayMode,bound:CGRect)->CIImage?{
        self.fillModel.filter(img: img, mode: mode, bound: bound)
    }
    public var displayMode:ImageFillMode.DisplayMode = .scaleAspectFit
}
