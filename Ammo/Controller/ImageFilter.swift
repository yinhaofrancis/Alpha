//
//  ImageFilter.swift
//  Ammo
//
//  Created by wenyang on 2022/10/8.
//

import CoreImage

public struct ImageGaussBlur{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIGaussianBlur")
    public func filter(radius:CGFloat?,image:CIImage?)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(radius, forKey: kCIInputRadiusKey)
        return gauss?.outputImage
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

public struct ImageCropGaussImage{
    public let gauss:ImageGaussBlur = ImageGaussBlur()
    public let crop:ImageCrop = ImageCrop()
    public let transform = ImageAffineTransform()
    public init() {}
    public func filter(radius:CGFloat,crop:Bool,translate:Bool,image:CIImage?)->CIImage?{
        guard let source = image else { return image }
        
        guard let img = self.gauss.filter(radius: radius, image: image) else { return image }
        if(crop){
            return self.crop.filter(rectangle: CIVector(cgRect: source.extent), image: img)
        }else{
            if(translate){
                return transform.filter(transform: CGAffineTransform(translationX: -img.extent.minX, y: -img.extent.minY), image: img)
            }else{
                return img
            }
            
        }
        
    }
}
public struct GradientGaussMask{
    public var colorMask:ImageColorMask = ImageColorMask()
    public var gradient:ImageLinearGradient = ImageLinearGradient()
    public var smgradient:ImageSmoothLinearGradient = ImageSmoothLinearGradient()
    public var gaussImage:ImageCropGaussImage = ImageCropGaussImage()
    public var blend:ImageBlendWithAlphaMask = ImageBlendWithAlphaMask()
    public init() {}
    public func filter(translate:Bool?,
                       linear:Bool?,
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
            result = self.gaussImage.filter(radius: radius, crop: false, translate: translate ?? false , image: result)
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