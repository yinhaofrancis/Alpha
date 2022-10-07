//
//  ImageDisplay.swift
//  Ammo
//
//  Created by wenyang on 2022/10/7.
//

import UIKit
import MetalKit

public class CoreImageView:UIView{

    public var image:CIImage?{
        didSet{
            self.invalidateIntrinsicContentSize()
            self.render()
        }
    }
    public var uiImage:UIImage?{
        didSet{
            guard let im = uiImage else { self.image = nil;return }
            self.image = CIImage(image: im)
        }
    }
    public override class var layerClass: AnyClass{
        return CAMetalLayer.self
    }

    public var mtlayer:CAMetalLayer{
        return self.layer as! CAMetalLayer
    }

    public func render(){
        guard let img = self.image else { return }
        MetalRender.shared.render(img: img, bound: self.nativeBound, filter: self.displayfilter, target: self.mtlayer)
    }
    public var nativeBound:CGRect{
        let bound = self.bounds;
        return CGRect(x: 0, y: 0, width: bound.width * UIScreen.main.scale, height: bound.height * UIScreen.main.scale)
    }
    private var displayfilter:ImageFilter = DisplayModeFilter()
}

public protocol ImageFilter{
    func filter(img:CIImage?,bound:CGRect)->CIImage?
}
public class MetalRender{

    public func render(img:CIImage,bound:CGRect,filter:ImageFilter,target:CAMetalLayer){
        target.device = self.device
        target.pixelFormat = .bgra8Unorm_srgb
        target.framebufferOnly = false
        target.colorspace = CGColorSpaceCreateDeviceRGB()
        target.contentsScale = UIScreen.main.scale
        self.dispatchQueue.async {
            guard let buffer = self.buffer else { return }
            guard let result = filter.filter(img: img, bound: bound) else { return }
            guard let ctx = self.ctx else { return }
            guard let drawable = target.nextDrawable() else { return }
            ctx.render(result, to: drawable.texture, commandBuffer: buffer, bounds: bound, colorSpace: CGColorSpaceCreateDeviceRGB())
            buffer.present(drawable)
            buffer.commit()
            buffer.waitUntilCompleted()
        }
    }
 
    private var buffer:MTLCommandBuffer?{
        self.queue?.makeCommandBuffer()
    }
    private lazy var queue:MTLCommandQueue? = {
        device?.makeCommandQueue()
    }()
    private lazy var ctx:CIContext? = {
        guard let queue = queue else {
            return nil
        }
        return CIContext(mtlCommandQueue: queue)
    }()
    private var device:MTLDevice? = MTLCreateSystemDefaultDevice()
    private var dispatchQueue:DispatchQueue = { DispatchQueue(label: "CoreImageView")}()
    
    public static let shared:MetalRender = MetalRender()
}
public class GaussGradientMaskBlendFilter:ImageFilter{
    public init() {}
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let img = img else { return nil }
        var current:CIImage? = img
        if let mask = self.colorMask{
            current = mask.filter(img: img, bound: img.extent)
        }
        
        if let gauss = self.gaussMask{
            current = gauss.filter(img: current, bound: bound)
        }
        if let p1 = self.start,
           let p2 = self.end,
            let c1 = self.startColor,
            let c2 = self.endColor{
            let c = GradientMaskFilter(point0: p1, point1: p2, color0: c1, color1: c2)
            current = c.filter(img: current, bound: bound)
        }
        
        return current
    }
    private var colorMask:ColorMaskFilter?
    private var gaussMask:GaussBlurFilter?
    public var start:CGPoint?
    public var end:CGPoint?
    public var startColor:CGColor?
    public var endColor:CGColor?
    public var maskColor:UIColor?{
        didSet{
            if maskColor != nil {
                var r:CGFloat = 0
                var g:CGFloat = 0
                var b:CGFloat = 0
                var a:CGFloat = 0
                self.maskColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
                let m = ColorMaskFilter(color: CIColor(red: r, green: g, blue: b), alpha: a)
                self.colorMask = m
            }else{
                self.colorMask = nil
            }
            
        }
    }
    
    public var gaussRadius:CGFloat?{
        didSet{
            if gaussRadius != nil{
                self.gaussMask = GaussBlurFilter(radius: self.gaussRadius!, needMax: true)
            }else{
                self.gaussMask = nil
            }
        }
    }
    
}

public class ColorMaskFilter:ImageFilter{
    public var color:CIColor
    public var alpha:CGFloat
    private let crop = CIFilter(name: "CICrop")
    public var clipBound:Bool = true
    
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let img = img else {
            return img
        }
        let outi = BlendMaskFilter(image: CIImage(color: self.color), mask: CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: alpha)), background: img).outImage
        crop?.setValue(outi, forKey: kCIInputImageKey)
        crop?.setValue(img.extent, forKey: "inputRectangle")
        if(clipBound){
            guard let out = crop?.outputImage else { return crop?.outputImage }
            return BlendMaskFilter(image: out, mask: img, background: nil).outImage
        }else{
            return crop?.outputImage
        }
        
    }
    public init(color:CIColor,alpha:CGFloat){
        self.color = color
        self.alpha = alpha
    }
    
}
public class BlendMaskFilter{
    public var blend = CIFilter(name: "CIBlendWithAlphaMask")
    public var image:CIImage
    public var mask:CIImage
    public var background:CIImage?
    public init(image:CIImage,mask:CIImage,background:CIImage?){
        self.image = image
        self.mask = mask
        self.background = background
    }
    public var outImage:CIImage?{
        blend?.setDefaults()
        blend?.setValue(self.image, forKey: kCIInputImageKey)
        blend?.setValue(self.background, forKey: kCIInputBackgroundImageKey)
        blend?.setValue(self.mask, forKey: kCIInputMaskImageKey)
        return blend?.outputImage
    }
}

public class GradientFilter{
    public var point0:CIVector
    public var point1:CIVector
    public var color0:CIColor
    public var color1:CIColor
    public var gradientfilter = CIFilter(name:"CILinearGradient")
    public var outImage:CIImage? {
        self.gradientfilter?.setValue(self.point0, forKey: "inputPoint0")
        self.gradientfilter?.setValue(self.point1, forKey: "inputPoint1")
        
        self.gradientfilter?.setValue(color0, forKey: "inputColor0")
        self.gradientfilter?.setValue(color1, forKey: "inputColor1")
        return self.gradientfilter?.outputImage
    }
    public init(point0:CIVector, point1:CIVector,color0:CIColor,color1:CIColor){
        self.point0 = point0
        self.point1 = point1
        self.color0 = color0
        self.color1 = color1
    }
}

public class GradientMaskFilter:ImageFilter{
    public var point0:CGPoint
    public var point1:CGPoint
    public var color0:CGColor
    public var color1:CGColor
    private let crop = CIFilter(name: "CICrop")
    public init(point0:CGPoint, point1:CGPoint,color0:CGColor,color1:CGColor){
        self.point0 = point0
        self.point1 = point1
        self.color0 = color0
        self.color1 = color1
    }
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let img = img else {
            return img
        }

        guard let g = self.createGradient(frame: img.extent, start: self.point0, end: self.point1, startColor: self.color0, endColor: self.color1).outImage else {
            return img
        }
        let out = BlendMaskFilter(image: img, mask: g, background: nil).outImage
        self.crop?.setValue(out, forKey: kCIInputImageKey)
        self.crop?.setValue(img.extent, forKey: "inputRectangle")
        return self.crop?.outputImage
    }
    private func createGradient(frame:CGRect,
                                start:CGPoint,
                                end:CGPoint,
                                startColor:CGColor,
                                endColor:CGColor)->GradientFilter{
        let civ1 = CIVector(x: frame.width * start.x, y: frame.height * start.y)
        let civ2 = CIVector(x: frame.width * end.x, y: frame.height * end.y)
        return GradientFilter(point0:civ1 , point1: civ2, color0: CIColor(cgColor: startColor), color1: CIColor(cgColor: endColor))
    }
}

public class GaussBlurFilter:ImageFilter{
    public init(radius:Double,needMax:Bool = false){
        self.needMax = needMax
        self.filter?.setValue(radius, forKey: kCIInputRadiusKey)
    }
    public let filter = CIFilter(name:"CIGaussianBlur")
    private let crop = CIFilter(name: "CICrop")
    public var needMax:Bool
    private let transform:CIFilter? = CIFilter(name: "CIAffineTransform");
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let source = img else { return img }
        self.filter?.setValue(source, forKey: kCIInputImageKey)
        guard let image = self.filter?.outputImage else { return self.filter?.outputImage }
        if(needMax){
            transform?.setValue(CGAffineTransform(translationX: -image.extent.minX, y: -image.extent.minY), forKey: "inputTransform")
            transform?.setValue(image, forKey: kCIInputImageKey)
            return transform?.outputImage
        }
        crop?.setValue(image, forKey: kCIInputImageKey)
        crop?.setValue(CIVector(cgRect: source.extent), forKey: "inputRectangle")
        return crop?.outputImage
    }
}

public class MixinFilter:ImageFilter{
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        self.filters.reduce(img) { partialResult, filter in
            filter.filter(img: partialResult, bound: bound)
        }
    }
    public var filters:[ImageFilter]
    public init(filters:[ImageFilter]){
        self.filters = filters
    }
}
public class DisplayModeFilter:ImageFilter{
    
    public enum DisplayMode:Int{
        case scaleToFill = 0
        case scaleAspectFit = 1
        case scaleAspectFill = 2
    }
    public init() {}
    public func filter(img: CIImage?, bound: CGRect) -> CIImage? {
        guard let i = img else { return img }
        guard let image = self.filter(img: i, mode: self.displayMode, bound: bound) else { return img }
        
        return self.process(image: image) ?? image
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
    
    public func process(image:CIImage)->CIImage?{
        guard let otherFilters = otherFilter else { return image }
        otherFilters.setValue(image, forKey: kCIInputImageKey)
        return otherFilters.outputImage
    }
    public var otherFilter:CIFilter?
}

