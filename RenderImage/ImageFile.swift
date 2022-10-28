//
//  ImageFile.swift
//  RenderImage
//
//  Created by wenyang on 2022/10/13.
//

import Foundation
import ImageIO
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices


public class WeakProxy<T:AnyObject>{
    weak var content:T?
    public init(content:T?){
        self.content = content
    }
}

public class WeakHashProxy<T:AnyObject>:Hashable where T:Hashable{
    public static func == (lhs: WeakHashProxy<T>, rhs: WeakHashProxy<T>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    weak var content:T?
    public init(content:T?){
        self.content = content
    }
    public func hash(into hasher: inout Hasher) {
        self.content.hash(into: &hasher)
    }
}

public typealias Filter = (CIImage?)->CIImage?

public class RIImage{
    public struct AnimationFrame{
        public var image:CIImage
        public var delay:TimeInterval
    }
    public var filter:Filter?
    private var source:CGImageSource
    private var cache:Bool = false
    public init?(finalData:Data){
        guard let ds = CGImageSourceCreateWithData(finalData as CFData, nil) else { return nil }
        self.source = ds
    }
    private var lock = DispatchSemaphore(value: 1)
    public init(){
        self.source = CGImageSourceCreateIncremental(nil)
    }
    public func set(data:Data,final:Bool = false){
        CGImageSourceUpdateData(source, data as CFData, final)
    }
    public var primaryImage:CIImage?{
        guard let cgimg = self[0]?.image else { return nil }
        
        return self.filter?(cgimg) ?? cgimg
    }

    public var count:Int{
        return CGImageSourceGetCount(self.source)
    }
    private var cacheFrame:[Int:AnimationFrame] = [:]
    public subscript(index:Int)->AnimationFrame?{
        self.lock.wait()
        if let fame = self.cacheFrame[index]{
            self.lock.signal()
            return fame
        }else{
            self.lock.signal()
            guard let image = self.image(index: index) else { return nil }
            let delay = self.delay(index: index)
            let ci = CIImage(cgImage: image)
            let frame = AnimationFrame(image: self.filter?(ci) ?? ci, delay: delay)
            self.lock.wait()
            self.cacheFrame[index] = frame
            self.lock.signal()
            return frame
        }
    }
    public func image(index:Int)->CGImage?{
        guard let image = CGImageSourceCreateImageAtIndex(self.source, index, [
            kCGImageSourceShouldCacheImmediately:self.cache,
            kCGImageSourceShouldCache:self.cache
        ] as CFDictionary) else { return nil }
        return image
    }
    private func delay(index:Int)->TimeInterval{
        guard let dic = CGImageSourceCopyPropertiesAtIndex(self.source, index, nil) as? Dictionary<String,Any> else {
            return 0
        }
        if let gif = dic[kCGImagePropertyGIFDictionary as String] as? Dictionary<String,Any>{
            return gif[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0
        }
        if let apng = dic[kCGImagePropertyPNGDictionary as String] as? Dictionary<String,Any>{
            return apng[kCGImagePropertyAPNGDelayTime as String] as? Double ?? 0
        }
        if let heic = dic[kCGImagePropertyHEICSDictionary as String] as? Dictionary<String,Any>{
            return heic[kCGImagePropertyHEICSDelayTime as String] as? Double ?? 0
        }
        if #available(iOSApplicationExtension 14.0, *) {
            if let WebP = dic[kCGImagePropertyWebPDictionary as String] as? Dictionary<String,Any>{
                return WebP[kCGImagePropertyWebPDelayTime as String] as? Double ?? 0
            }
        }
        return 0
    }
}
extension CGImage{
    public var bitmap:CGImage?{
        guard let dp = self.dataProvider?.data else { return self }
        let md = CFDataCreateMutableCopy(kCFAllocatorDefault, CFDataGetLength(dp), dp)
        return CGContext(data: CFDataGetMutableBytePtr(md), width: self.width, height: self.height, bitsPerComponent: self.bitsPerComponent, bytesPerRow: self.bytesPerRow, space: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: self.bitmapInfo.rawValue)?.makeImage()
    }
    public var png:CGImage?{
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else { return nil }
        guard let destination = CGImageDestinationCreateWithData(data,CGImage.pngType as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        CGImageDestinationFinalize(destination)
        guard let dp = CGDataProvider(data: data) else { return nil }
        return CGImage(pngDataProviderSource: dp, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
    public func jpg(quality:Float)->CGImage?{
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else { return nil }
        guard let destination = CGImageDestinationCreateWithData(data,CGImage.jpgType as CFString, 1, [kCGImageDestinationLossyCompressionQuality:quality] as CFDictionary) else { return nil }
        CGImageDestinationAddImage(destination, self, [kCGImageDestinationLossyCompressionQuality:quality] as CFDictionary)
        CGImageDestinationFinalize(destination)
        guard let dp = CGDataProvider(data: data) else { return nil }
        return CGImage(jpegDataProviderSource: dp, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
    static var pngType:String{
        if #available(iOS 14.0, *) {
            return UTType.png.identifier
        } else {
            return kUTTypePNG as String
        }
    }
    static var jpgType:String{
        if #available(iOS 14.0, *) {
            return UTType.jpeg.identifier
        } else {
            return kUTTypeJPEG as String
        }
    }
}
