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


public class MemoryImage{
    public var image:CGImage?
}

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


public struct RIImage{
    private var source:CGImageSource
    private var cache:Bool = false
    public init?(finalData:Data){
        guard let ds = CGImageSourceCreateWithData(finalData as CFData, nil) else { return nil }
        self.source = ds
    }
    public init(){
        self.source = CGImageSourceCreateIncremental(nil)
    }
    public mutating func set(data:Data,final:Bool = false){
        CGImageSourceUpdateData(source, data as CFData, final)
    }
    public var count:Int{
        return CGImageSourceGetCount(self.source)
    }
    public subscript(index:Int)->CGImage?{
        return CGImageSourceCreateImageAtIndex(self.source, index, [
            kCGImageSourceShouldCacheImmediately:self.cache,
            kCGImageSourceShouldCache:self.cache
        ] as CFDictionary)
    }
    public func thumbnail(index:Int)->CGImage?{
        return CGImageSourceCreateThumbnailAtIndex(self.source, index,[
            kCGImageSourceShouldCacheImmediately:self.cache,
            kCGImageSourceShouldCache:self.cache
        ] as CFDictionary)
    }
}
extension CGImage{
    public var bitmap:CGImage?{
        guard let dp = self.dataProvider?.data else { return self }
        let md = CFDataCreateMutableCopy(kCFAllocatorDefault, CFDataGetLength(dp), dp)
        return CGContext(data: CFDataGetMutableBytePtr(md), width: self.width, height: self.height, bitsPerComponent: self.bitsPerComponent, bytesPerRow: self.bytesPerRow, space: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: self.bitmapInfo.rawValue)?.makeImage()
    }
}
