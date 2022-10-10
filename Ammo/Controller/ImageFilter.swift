//
//  ImageFilter.swift
//  Ammo
//
//  Created by wenyang on 2022/10/8.
//

import CoreImage


public protocol ImageBlur{
    func filter(radius:CGFloat?,image:CIImage?)->CIImage?
    init()
}

public struct ImageGaussianBlur:ImageBlur{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIGaussianBlur")
    public func filter(radius:CGFloat?,image:CIImage?)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(radius, forKey: kCIInputRadiusKey)
        return gauss?.outputImage
    }
}

public struct ImageBoxBlur:ImageBlur{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIBoxBlur")
    public func filter(radius:CGFloat?,image:CIImage?)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(radius, forKey: kCIInputRadiusKey)
        return gauss?.outputImage
    }
}

public struct ImageDiscBlur:ImageBlur{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIDiscBlur")
    public func filter(radius:CGFloat?,image:CIImage?)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(radius, forKey: kCIInputRadiusKey)
        return gauss?.outputImage
    }
}

public struct ImageCropBlurImage<Blur:ImageBlur>{
    public let gauss:Blur = Blur()
    public let crop:ImageCrop = ImageCrop()
    public init() {}
    public func filter(radius:CGFloat,crop:Bool,image:CIImage?)->CIImage?{
        guard let source = image else { return image }
        
        guard let img = self.gauss.filter(radius: radius, image: image) else { return image }
        if(crop){
            return self.crop.filter(rectangle: CIVector(cgRect: source.extent), image: img)
        }
        return img
        
    }
}



public struct ImageExposureAdjust{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIExposureAdjust")
    public func filter(ev:CGFloat?,image:CIImage?)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(ev, forKey: kCIInputEVKey)
        return gauss?.outputImage
    }
}

public struct ImageColorControls{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIColorControls")
    public func filter(saturation:CGFloat?,brightness:CGFloat?,contrast:CGFloat?,image:CIImage?)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(saturation, forKey: kCIInputSaturationKey)
        gauss?.setValue(brightness, forKey: kCIInputBrightnessKey)
        gauss?.setValue(contrast, forKey: kCIInputContrastKey)
        return gauss?.outputImage
    }
}

public struct ImageCrop{
    public init() {}
    public var crop = CIFilter(name: "CICrop")
    public func filter(rectangle:CIVector?,image:CIImage?)->CIImage?{
        self.crop?.setDefaults()
        self.crop?.setValue(image, forKey: kCIInputImageKey)
        self.crop?.setValue(rectangle, forKey: "inputRectangle")
        return self.crop?.outputImage
    }
}
public struct ImageAffineTransform{
    public init() {}
    public var transform = CIFilter(name: "CIAffineTransform")
    
    public func filter(transform:CGAffineTransform?,image:CIImage?)->CIImage?{
        self.transform?.setDefaults()
        self.transform?.setValue(image, forKey: kCIInputImageKey)
        self.transform?.setValue(transform, forKey: "inputTransform")
        return self.transform?.outputImage
    }
}

public struct ImageAffineClamp{
    public init() {}
    public var transform = CIFilter(name: "CIAffineClamp")
    
    public func filter(transform:CGAffineTransform?,image:CIImage?)->CIImage?{
        self.transform?.setDefaults()
        self.transform?.setValue(image, forKey: kCIInputImageKey)
        self.transform?.setValue(transform, forKey: "inputTransform")
        return self.transform?.outputImage
    }
}
public struct ImageAffineTile{
    public init() {}
    public var transform = CIFilter(name: "CIAffineClamp")
    
    public func filter(transform:CGAffineTransform?,image:CIImage?)->CIImage?{
        self.transform?.setDefaults()
        self.transform?.setValue(image, forKey: kCIInputImageKey)
        self.transform?.setValue(transform, forKey: "inputTransform")
        return self.transform?.outputImage
    }
}
public struct ImageLinearGradient{
    public init() {}
    public var gradient = CIFilter(name: "CILinearGradient")
    public func filter(point0:CIVector,point1:CIVector,color0:CIColor,color1:CIColor)->CIImage?{
        self.gradient?.setDefaults()
        self.gradient?.setValue(point0, forKey: "inputPoint0")
        self.gradient?.setValue(point1, forKey: "inputPoint1")
        self.gradient?.setValue(color0, forKey: "inputColor0")
        self.gradient?.setValue(color1, forKey: "inputColor1")
        return self.gradient?.outputImage
    }
}
public struct ImageSmoothLinearGradient{
    public init() {}
    public var gradient = CIFilter(name: "CISmoothLinearGradient")
    public func filter(point0:CIVector,point1:CIVector,color0:CIColor,color1:CIColor)->CIImage?{
        self.gradient?.setDefaults()
        self.gradient?.setValue(point0, forKey: "inputPoint0")
        self.gradient?.setValue(point1, forKey: "inputPoint1")
        self.gradient?.setValue(color0, forKey: "inputColor0")
        self.gradient?.setValue(color1, forKey: "inputColor1")
        return self.gradient?.outputImage
    }
}

public struct ImageBlendWithAlphaMask{
    public init() {}
    public var blend = CIFilter(name: "CIBlendWithAlphaMask")
    public func filter(image:CIImage?,mask:CIImage?,background:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(mask, forKey: kCIInputMaskImageKey)
        self.blend?.setValue(background, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}

public struct ImageBlendWithMask{
    public init() {}
    public var blend = CIFilter(name: "CIBlendWithMask")
    public func filter(image:CIImage?,mask:CIImage?,background:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(mask, forKey: kCIInputMaskImageKey)
        self.blend?.setValue(background, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}

public struct ImageColorMask{
    public var blend = ImageBlendWithAlphaMask()
    public var crop = ImageCrop()
    public init() {}
    public func filter(color:CIColor,alpha:CGFloat,image:CIImage?)->CIImage?{
        guard let img = self.blend.filter(image:CIImage(color: color) , mask: CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: alpha)), background: image) else { return image }
        return self.blend.filter(image: img, mask: image, background: nil)
    }
}
public struct GradientGaussMask{
    public var colorMask:ImageColorMask = ImageColorMask()
    public var gradient:ImageLinearGradient = ImageLinearGradient()
    public var smgradient:ImageSmoothLinearGradient = ImageSmoothLinearGradient()
    public var gaussImage:ImageCropBlurImage = ImageCropBlurImage<ImageGaussianBlur>()
    public var blend:ImageBlendWithAlphaMask = ImageBlendWithAlphaMask()
    public init() {}
    public func filter(linear:Bool?,
                       point0:CGPoint?,
                       point1:CGPoint?,
                       color:CIColor?,
                       alpha:CGFloat?,
                       radius:CGFloat?,
                       image:CIImage?)->CIImage?{
        
        guard let image = image else { return nil }
        var result:CIImage? = image
        if let color = color ,let alpha = alpha{
            result = self.colorMask.filter(color: color, alpha: alpha, image: result)
        }
        if let radius = radius {
            result = self.gaussImage.filter(radius: radius, crop: false, image: result)
        }
        if let po = point0, let p1 = point1,let result = result{
            let cv1 = CIVector(x: po.x * result.extent.width, y: po.y * result.extent.height)
            let cv2 = CIVector(x: p1.x * result.extent.width, y: p1.y * result.extent.height)
            let g = (linear ?? true) ? self.gradient.filter(point0: cv1, point1: cv2, color0: CIColor(red: 0, green: 0, blue: 0, alpha: 0), color1: CIColor(red: 0, green: 0, blue: 0, alpha: 1)) : self.smgradient.filter(point0: cv1, point1: cv2, color0: CIColor(red: 0, green: 0, blue: 0, alpha: 0), color1: CIColor(red: 0, green: 0, blue: 0, alpha: 1))
            return self.blend.filter(image: result, mask: g, background: nil)
            
        }
        return image
    }
}

public struct ImageDissolveTransition{
    public init() {}
    public var transition = CIFilter(name:"CIDissolveTransition")
    public func filter(image:CIImage?,target:CIImage?,time:CGFloat)->CIImage?{
        self.transition?.setDefaults()
        self.transition?.setValue(image, forKey: kCIInputImageKey)
        self.transition?.setValue(target, forKey: kCIInputTargetImageKey)
        self.transition?.setValue(time, forKey: kCIInputTimeKey)
        return self.transition?.outputImage
    }
}
public struct ImageSourceIn{
    public init() {}
    public var blend = CIFilter(name:"CISourceInCompositing")
    public func filter(image:CIImage?,imageBackground:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(imageBackground, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}
public struct ImageSourceOut{
    public init() {}
    public var blend = CIFilter(name:"CISourceOutCompositing")
    public func filter(image:CIImage?,imageBackground:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(imageBackground, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}
public struct ImageSourceOver{
    public init() {}
    public var blend = CIFilter(name:"CISourceOverCompositing")
    public func filter(image:CIImage?,imageBackground:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(imageBackground, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}
public struct ImageSourceAtop{
    public init() {}
    public var blend = CIFilter(name:"CISourceAtopCompositing")
    public func filter(image:CIImage?,imageBackground:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(imageBackground, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}
public struct ImageFillMode{
    
    public enum DisplayMode:Int{
        case scaleToFill = 0
        case scaleAspectFit = 1
        case scaleAspectFill = 2
    }
    
    public init() {}
    public var transform = ImageAffineTransform()
    
    public func filter(img:CIImage?,mode:DisplayMode?,bound:CGRect?)->CIImage?{
        guard let img = img else {
            return img
        }
        guard let mode = mode else {
            return img
        }
        guard let bound = bound else {
            return img
        }
        var result:CIImage?
        var scale:CGFloat = 1;
        if mode == .scaleAspectFill{
            scale = max(bound.width / img.extent.width, bound.height / img.extent.height)
            let scaleTransFor = CGAffineTransform(scaleX: scale, y: scale)
            
            let endFrame = img.extent.applying(scaleTransFor)
            let deltax = (bound.width - endFrame.width) / 2 - endFrame.minX
            let deltay = (bound.height - endFrame.height) / 2 - endFrame.minY
            result = self.transform.filter(transform: CGAffineTransform(translationX: deltax, y: deltay).scaledBy(x: scale, y: scale), image: img)
        }else if mode == .scaleAspectFit{
            scale = min(bound.width / img.extent.width, bound.height / img.extent.height)
            let scaleTransFor = CGAffineTransform(scaleX: scale, y: scale)
            
            let endFrame = img.extent.applying(scaleTransFor)
            let deltax = (bound.width - endFrame.width) / 2 - endFrame.minX
            let deltay = (bound.height - endFrame.height) / 2 - endFrame.minY
            result = self.transform.filter(transform: CGAffineTransform(translationX: deltax, y: deltay).scaledBy(x: scale, y: scale), image: img)
        }else{
            let x = bound.width / img.extent.width
            let y = bound.height / img.extent.height
            result = self.transform.filter(transform: CGAffineTransform(scaleX: x, y: y), image: img)
        }
        return result
    }
}

public class ImageGaussianBackground{
    public init() {}
    public var gauss = ImageCropBlurImage<ImageGaussianBlur>()
    public var displayModel = ImageFillMode()
    public var blend = ImageSourceOver()
    public var crop = ImageCrop()
    public func filter(bound:CGRect,
                       image:CIImage?,
                       radius:CGFloat?,
                       backgroundColor:CIColor? = nil)->CIImage?{
        let nb = self.displayModel.filter(img: image, mode: .scaleAspectFill, bound: bound)
        let cb = self.crop.filter(rectangle: CIVector(cgRect: bound), image: nb)
        let bg = self.gauss.filter(radius: radius ?? 10, crop: true, image: cb);
        let fo = self.displayModel.filter(img: image, mode: .scaleAspectFit, bound: bound)
        let outFace = self.blend.filter(image: fo, imageBackground: bg)
        if let bgc = backgroundColor{
            let bgb = self.crop.filter(rectangle: CIVector(cgRect: bound), image: CIImage(color: bgc))
            return self.blend.filter(image: outFace, imageBackground: bgb)
        }else{
            return outFace
        }
    }
}

@dynamicCallable
public struct ImageFilter{
    public var filter:CIFilter
    public func dynamicallyCall(withKeywordArguments:KeyValuePairs<String,Any>)->CIImage?{
        withKeywordArguments.forEach { kv in
            filter.setValue(kv.value, forKey: kv.key)
        }
        return filter.outputImage
    }
    public init?(name:String){
        guard let f = CIFilter(name: name) else { return nil }
        self.filter = f
    }
}
