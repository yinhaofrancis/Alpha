//
//  ImageFilter.swift
//  Ammo
//
//  Created by wenyang on 2022/10/8.
//

import CoreImage

public enum BlurType:String{
    case Gaussian = "CIGaussianBlur"
    case Box = "CIBoxBlur"
    case Disc = "CIDiscBlur"
}

public enum AffineType:String{
    case Transform = "CIAffineTransform"
    case Clamp = "CIAffineClamp"
    case Tile = "CIAffineTile"
}

public enum ConvolutionType:String{
    case Convolution3x3 = "CIConvolution3x3"
    case Convolution5x5 = "CIConvolution5x5"
    case Convolution7x7 = "CIConvolution7x7"
    case Convolution9Horizontal = "CIConvolution9Horizontal"
    case Convolution9Vertical = "CIConvolution9Vertical"
}

public enum ImageBlendType:String{
    case Addition = "CIAdditionCompositing"
    case Color = "CIColorBlendMode"
    case ColorBurn = "CIColorBurnBlendMode"
    case ColorDodge = "CIColorDodgeBlendMode"
    case Darken = "CIDarkenBlendMode"
    case Difference = "CIDifferenceBlendMode"
    case Divide = "CIDivideBlendMode"
    case Exclusion = "CIExclusionBlendMode"
    case HardLight = "CIHardLightBlendMode"
    case Hue = "CIHueBlendMode"
    case Lighten = "CILightenBlendMode"
    case LinearBurn = "CILinearBurnBlendMode"
    case LinearDodge = "CILinearDodgeBlendMode"
    case Luminosity = "CILuminosityBlendMode"
    case Maximum = "CIMaximumCompositing"
    case Minimum = "CIMinimumCompositing"
    case MultiplyBlend = "CIMultiplyBlendMode"
    case MultiplyCompositing = "CIMultiplyCompositing"
    case Overlay = "CIOverlayBlendMode"
    case PinLight = "CIPinLightBlendMode"
    case Saturation = "CISaturationBlendMode"
    case Screen = "CIScreenBlendMode"
    case SoftLight = "CISoftLightBlendMode"
    case SourceAtop = "CISourceAtopCompositing"
    case SourceIn = "CISourceInCompositing"
    case SourceOut = "CISourceOutCompositing"
    case SourceOver = "CISourceOverCompositing"
    case Subtract = "CISubtractBlendMode"
}

public enum LinearGradientType:String{
    case Linear = "CILinearGradient"
    case SmoothLinear = "CISmoothLinearGradient"
}

public enum BlendMaskType:String{
    case BlendMask = "CIBlendWithMask"
    case BlendAlphaMask = "CIBlendWithAlphaMask"
}

public enum PhotoEffectType:String{
    case Chrome     = "CIPhotoEffectChrome"
    case Fade       = "CIPhotoEffectFade"
    case Instant    = "CIPhotoEffectInstant"
    case Mono       = "CIPhotoEffectMono"
    case Noir       = "CIPhotoEffectNoir"
    case Proc       = "CIPhotoEffectProcess"
    case Tonal      = "CIPhotoEffectTonal"
    case Transfer   = "CIPhotoEffectTransfer"
}
public struct ImagePhoto{
    public init(type:PhotoEffectType){
        self.photo = CIFilter(name: type.rawValue)
    }
    public func filter(image:CIImage?)->CIImage?{
        self.photo?.setDefaults()
        self.photo?.setValue(image, forKey: kCIInputImageKey)
        return self.photo?.outputImage
    }
    
    public var photo:CIFilter?
}


//blur
public struct ImageBlur{
    public func filter(radius:CGFloat?,image:CIImage?)->CIImage?{
        blur?.setDefaults()
        blur?.setValue(image, forKey: kCIInputImageKey)
        blur?.setValue(radius, forKey: kCIInputRadiusKey)
        return blur?.outputImage
    }
    public init(type:BlurType){
        self.blur = CIFilter(name: type.rawValue)
    }
    public var blur:CIFilter?
}
// affine



public struct ImageAffine{
    public func filter(transform:CGAffineTransform?,image:CIImage?)->CIImage?{
        self.transform?.setDefaults()
        self.transform?.setValue(image, forKey: kCIInputImageKey)
        self.transform?.setValue(transform, forKey: "inputTransform")
        return self.transform?.outputImage
    }
    public init(type:AffineType){
        self.transform = CIFilter(name: type.rawValue)
    }
    public var transform:CIFilter?
}

// linear gradient

public struct ImageLinearGradient{
    public init(type:LinearGradientType){
        self.gradient = CIFilter(name: type.rawValue)
    }
    public var gradient:CIFilter?
    public func filter(point0:CIVector,point1:CIVector,color0:CIColor,color1:CIColor)->CIImage?{
        self.gradient?.setDefaults()
        self.gradient?.setValue(point0, forKey: "inputPoint0")
        self.gradient?.setValue(point1, forKey: "inputPoint1")
        self.gradient?.setValue(color0, forKey: "inputColor0")
        self.gradient?.setValue(color1, forKey: "inputColor1")
        return self.gradient?.outputImage
    }
}


//blend mask
public struct ImageBlendMask{
    public init(type:BlendMaskType){
        self.blend = CIFilter(name: type.rawValue)
    }
    public var blend:CIFilter?
    public func filter(image:CIImage?,mask:CIImage?,background:CIImage?)->CIImage?{
        self.blend?.setDefaults()
        self.blend?.setValue(image, forKey: kCIInputImageKey)
        self.blend?.setValue(mask, forKey: kCIInputMaskImageKey)
        self.blend?.setValue(background, forKey: kCIInputBackgroundImageKey)
        return self.blend?.outputImage
    }
}
// blend
public struct ImageBlend{
    public var filter:CIFilter?
    public init(blendType:ImageBlendType){
        self.filter = CIFilter(name: blendType.rawValue)
    }
    public func filter(image:CIImage?,imageBackground:CIImage?)->CIImage?{
        self.filter?.setDefaults()
        self.filter?.setValue(image, forKey: kCIInputImageKey)
        self.filter?.setValue(imageBackground, forKey: kCIInputBackgroundImageKey)
        return self.filter?.outputImage
    }
}

// convolution

public struct ImageConvolution{
    public init(type:ConvolutionType){
        self.convolution = CIFilter(name: type.rawValue)
    }
    public var convolution:CIFilter?
    public func filter(image:CIImage?,weight:CIVector?,bias:CGFloat?)->CIImage?{
        self.convolution?.setDefaults()
        self.convolution?.setValue(image, forKey: kCIInputImageKey)
        self.convolution?.setValue(weight, forKey: kCIInputWeightsKey)
        self.convolution?.setValue(bias, forKey: kCIInputBiasKey)
        return self.convolution?.outputImage
    }
}

public enum ColoredSquaresType:String{
    case HexagonalPixellate = "CIHexagonalPixellate"
    case Pixellate = "CIPixellate"
    case Crystallize = "CICICrystallize"
    case Pointillize = "CIPointillize"
}

public struct ImageColoredSquares{
    public init(type:ColoredSquaresType){
        self.pixellate = CIFilter(name: type.rawValue)
        switch(type){
            
        case .HexagonalPixellate:
            self.radius = false
            break
        case .Pixellate:
            self.radius = false
            break
        case .Crystallize:
            self.radius = true
            break
        case .Pointillize:
            self.radius = true
            break
        }
    }
    public func filter(image:CIImage?,center:CIVector?,scale:CGFloat)->CIImage?{
        self.pixellate?.setDefaults()
        if(self.radius){
            self.pixellate?.setValue(image, forKey: kCIInputImageKey)
            self.pixellate?.setValue(center, forKey: kCIInputCenterKey)
            self.pixellate?.setValue(scale, forKey: kCIInputRadiusKey)
        }else{
            self.pixellate?.setValue(image, forKey: kCIInputImageKey)
            self.pixellate?.setValue(center, forKey: kCIInputCenterKey)
            self.pixellate?.setValue(scale, forKey: kCIInputScaleKey)
        }
        
        return self.pixellate?.outputImage
    }
    public var pixellate:CIFilter?
    public var radius:Bool
}

// other
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
public struct ImageColorMonochrome{
    public init() {}
    public var gauss:CIFilter? = CIFilter(name: "CIColorMonochrome")
    public func filter(image:CIImage?,color:CIColor,intensity:CGFloat)->CIImage?{
        gauss?.setDefaults()
        gauss?.setValue(image, forKey: kCIInputImageKey)
        gauss?.setValue(intensity, forKey: kCIInputIntensityKey)
        gauss?.setValue(color, forKey: kCIInputColorKey)
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
public struct ImageHeightFieldFromMask{
    public var transition = CIFilter(name:"CIHeightFieldFromMask")
    public func filter(image:CIImage?,radius:CGFloat?)->CIImage?{
        self.transition?.setDefaults()
        self.transition?.setValue(image, forKey: kCIInputImageKey)
        self.transition?.setValue(radius, forKey: kCIInputRadiusKey)
        return self.transition?.outputImage
    }
}
public struct ImageShadedMaterial{
    public var transition = CIFilter(name:"CIShadedMaterial")
    public func filter(image:CIImage?,shadingImage:CIImage?,scale:CGFloat?)->CIImage?{
        self.transition?.setDefaults()
        self.transition?.setValue(image, forKey: kCIInputImageKey)
        self.transition?.setValue(scale, forKey: kCIInputScaleKey)
        self.transition?.setValue(shadingImage, forKey: kCIInputShadingImageKey)
        return self.transition?.outputImage
    }
}

//custom

public struct ImageCropBlurImage{
    public let gauss:ImageBlur
    public let crop:ImageCrop = ImageCrop()
    public init(type:BlurType) {
        self.gauss = ImageBlur(type: type)
    }
    public func filter(radius:CGFloat,crop:Bool,image:CIImage?)->CIImage?{
        guard let source = image else { return image }
        
        guard let img = self.gauss.filter(radius: radius, image: image) else { return image }
        if(crop){
            return self.crop.filter(rectangle: CIVector(cgRect: source.extent), image: img)
        }
        return img
        
    }
}




public struct ImageColorMask{
    public var blend = ImageBlendMask(type: .BlendAlphaMask)
    public var crop = ImageCrop()
    public init() {}
    public func filter(color:CIColor,alpha:CGFloat,image:CIImage?)->CIImage?{
        guard let img = self.blend.filter(image:CIImage(color: color) , mask: CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: alpha)), background: image) else { return image }
        return self.blend.filter(image: img, mask: image, background: nil)
    }
}
public struct ImageScale{
    public init() {}
    public var transform = ImageAffine(type: .Transform)
    public func filter(scale:CGFloat,image:CIImage?)->CIImage?{
        self.transform.filter(transform: CGAffineTransform(scaleX: scale, y: scale), image: image)
    }
}
public struct GradientGaussMask{
    public var colorMask:ImageColorMask = ImageColorMask()
    public var gradient = ImageLinearGradient(type: .Linear)
    public var smgradient = ImageLinearGradient(type: .SmoothLinear)
    public var gaussImage:ImageCropBlurImage = ImageCropBlurImage(type: .Gaussian)
    public var blend:ImageBlendMask = ImageBlendMask(type: .BlendAlphaMask)
    public var crop:ImageCrop = ImageCrop()
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
            result = self.gaussImage.filter(radius: radius, crop: true, image: result)
        }
        if let po = point0, let p1 = point1,let result = result{
            let cv1 = CIVector(x: po.x * result.extent.width, y: po.y * result.extent.height)
            let cv2 = CIVector(x: p1.x * result.extent.width, y: p1.y * result.extent.height)
            let g = (linear ?? true) ? self.gradient.filter(point0: cv1, point1: cv2, color0: CIColor(red: 0, green: 0, blue: 0, alpha: 0), color1: CIColor(red: 0, green: 0, blue: 0, alpha: 1)) : self.smgradient.filter(point0: cv1, point1: cv2, color0: CIColor(red: 0, green: 0, blue: 0, alpha: 0), color1: CIColor(red: 0, green: 0, blue: 0, alpha: 1))
            guard let img = self.blend.filter(image: result, mask: g, background: nil) else {
                return image
            }
            return img
            
        }
        return image
    }
}

public struct ImageFillMode{
    
    public enum DisplayMode:Int{
        case scaleToFill = 0
        case scaleAspectFit = 1
        case scaleAspectFill = 2
    }
    
    public init() {}
    public var transform = ImageAffine(type: .Transform)
    
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
            let endFrame = img.extent.applying(CGAffineTransform(scaleX: x, y: y));
            result = self.transform.filter(transform: CGAffineTransform(scaleX: x, y: y).translatedBy(x: -endFrame.width, y: -endFrame.height),image: img)
        }
        return result
    }
}

public class ImageGaussianBackground{
    public init() {}
    public var gauss = ImageCropBlurImage(type: .Gaussian)
    public var displayModel = ImageFillMode()
    public var blend = ImageBlend(blendType:.SourceOver)
    public var crop = ImageCrop()
    public var remove = RemoveAlpha()
    public func filter(bound:CGRect,
                       image:CIImage?,
                       radius:CGFloat?)->CIImage?{
        let nb = self.displayModel.filter(img: image, mode: .scaleAspectFill, bound: bound)
        let cb = self.crop.filter(rectangle: CIVector(cgRect: bound), image: nb)
        let bg = self.gauss.filter(radius: radius ?? 10, crop: true, image: cb);
        let fo = self.displayModel.filter(img: image, mode: .scaleAspectFit, bound: bound)
        let outFace = self.blend.filter(image: fo, imageBackground: bg)
        return self.remove.filter(image: outFace)
    }
}

public struct imageShadow{
    public init () {}
    public let colorMask = ImageBlend(blendType: .SourceIn)
    public let affine = ImageAffine(type: .Transform)
    public let blur = ImageBlur(type: .Box)
    public let over = ImageBlend(blendType: .SourceOver)
    public func filter(image:CIImage?,color:CIColor?,offset:CGSize,radius:CGFloat)->CIImage?{
        guard let color = color else { return image }
        var result = self.colorMask.filter(image: CIImage(color: color), imageBackground: image)
        result = affine.filter(transform: CGAffineTransform(translationX: offset.width, y: -offset.height), image: result)
        result = blur.filter(radius: radius , image: result)
        return over.filter(image: image, imageBackground: result)
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


public class KernelLibray{
    private convenience init() throws{
        try self.init(name: "default")
    }
    public let data:Data
    public init(name:String,bundle:Bundle = Bundle(for: KernelLibray.self)) throws{
        guard let url = bundle.url(forResource: name, withExtension: "metallib") else {throw NSError(domain: "don't find metallib", code: 0)}
        data = try Data(contentsOf: url)
    }
    public func colorKernel(function:String)throws ->CIColorKernel{
        try CIColorKernel(functionName: function, fromMetalLibraryData: data)
    }
    
    public func wrapKernel(function:String)throws ->CIWarpKernel?{
        try CIWarpKernel(functionName: function, fromMetalLibraryData: data)
    }
    public func blendKernel(function:String)throws ->CIBlendKernel?{
        try CIBlendKernel(functionName: function, fromMetalLibraryData: data)
    }
    public func kernel(function:String) throws ->CIKernel{
        try CIKernel(functionName: function, fromMetalLibraryData: data)
    }
    public static let shared:KernelLibray = try! KernelLibray()
}

public struct RemoveAlpha{
    public init() {
        self.zip = try? KernelLibray.shared.colorKernel(function: "ZipAlpha")
    }
    let zip:CIColorKernel?
    public func filter(image:CIImage?)->CIImage?{
        guard let img = image else { return nil }
        return zip?.apply(extent: img.extent, arguments: [img])
    }
}
