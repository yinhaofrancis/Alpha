//
//  Context.swift
//  Ammo
//
//  Created by wenyang on 2022/5/27.
//

import Foundation
import QuartzCore
import CoreText
import UIKit
import UniformTypeIdentifiers

import CoreServices


/// fill 拉伸填充 fillScale 放大填充 fillScaleClip 放大填充剪切 scale 适应填充
public enum DrawImageMode{
    case fill
    case fillScale
    case fillScaleClip
    case scale
}

public struct RenderContext{
    public private(set) var context:CGContext
    public let scale:CGFloat
    public init(size:CGSize,scale:CGFloat,reverse:Bool = false) throws{
        self.scale = scale
        guard let ctx =  RenderContext.context(size: size, scale: scale)  else { throw NSError(domain: "create ctx error", code: 0) }
        self.context = ctx
        if(reverse){
            self.context.scaleBy(x: scale, y: -scale)
            self.context.translateBy(x: 0, y: -size.height)
        }
    }
    public init(ctx:CGContext,scale:CGFloat){
        self.context = ctx
        self.scale = scale
    }
    public static func context(size:CGSize,scale:CGFloat)->CGContext?{
        let w = Int(size.width * scale)
        return CGContext(data: nil, width:  w , height: Int(size.height * scale), bitsPerComponent: 8, bytesPerRow: 4 * w , space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
    }
    public func begin(call:(RenderContext)->Void){
        self.context.saveGState()
        call(self)
        self.context.restoreGState()
    }
    @available(iOS 13.0, *)
    public func render(_ call:@escaping (RenderContext)->Void) async ->CGImage?{
        return await Task {
            self.syncRender(call)
        }.value
    }
    public func syncRender(_ call:(RenderContext)->Void) ->CGImage?{
        self.begin(call:call)
        return self.image
    }
    public func drawImage(image:CGImage,rect:CGRect){
        self.begin { ctx in
            ctx.context.translateBy(x: rect.origin.x, y: rect.origin.y)
            ctx.context.scaleBy(x: 1, y: -1)
            ctx.context.translateBy(x: 0, y: -rect.height)
            ctx.context.draw(image, in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        }
    }
    public func drawScaleImage(image:CGImage,rect:CGRect,mode:DrawImageMode = .fill){
        switch(mode){
            
        case .fill:
            self.drawImage(image: image, rect: rect)
            break
        case .fillScale,.fillScaleClip:
            if image.width < image.height{
                let ratio = rect.width / CGFloat(image.width)
                let size = CGSize(width: rect.width, height: CGFloat(image.height) * ratio)
                let delta = (size.height - rect.height) / 2
                let frame = CGRect(x: rect.minX, y: rect.minY - delta, width: size.width, height: size.height)
                if mode == .fillScaleClip{
                    self.context.addPath(CGPath(rect: rect, transform: nil))
                    self.context.clip()
                }
                self.drawImage(image: image, rect: frame)
            }else{
                let ratio = rect.height / CGFloat(image.height)
                let size = CGSize(width: CGFloat(image.width) * ratio, height: rect.height)
                let delta = (size.width - rect.width) / 2
                let frame = CGRect(x: rect.minX - delta, y: rect.minY , width: size.width, height: size.height)
                self.drawImage(image: image, rect: frame)
            }
        case .scale:
            if image.width > image.height{
                let ratio = rect.width / CGFloat(image.width)
                let size = CGSize(width: rect.width, height: CGFloat(image.height) * ratio)
                let delta = (size.height - rect.height) / 2
                let frame = CGRect(x: rect.minX, y: rect.minY - delta, width: size.width, height: size.height)
                self.drawImage(image: image, rect: frame)
            }else{
                let ratio = rect.height / CGFloat(image.height)
                let size = CGSize(width: CGFloat(image.width) * ratio, height: rect.height)
                let delta = (size.width - rect.width) / 2
                let frame = CGRect(x: rect.minX - delta, y: rect.minY , width: size.width, height: size.height)
                self.drawImage(image: image, rect: frame)
            }
        }
    }
    public func drawFrame(frame:CTFrame,rect:CGRect){
        self.begin { ctx in
            ctx.context.translateBy(x: rect.origin.x, y: rect.origin.y)
            ctx.context.scaleBy(x: 1, y: -1)
            ctx.context.translateBy(x: 0, y: -rect.height)
            CTFrameDraw(frame, ctx.context)
        }
    }
    public func drawString(string:CFAttributedString,constaint:CGRect,alignX:CGFloat = 0,AlignY:CGFloat = 0){
        var size = constaint.size
        size.width = constaint.size.width < 0 ? CGFloat.infinity : constaint.size.width
        size.height = constaint.size.height < 0 ? CGFloat.infinity : constaint.size.height
        let frameset = CTFramesetterCreateWithAttributedString(string)
        let range = CFRange(location: 0, length: CFAttributedStringGetLength(string))
        let display = CTFramesetterSuggestFrameSizeWithConstraints(frameset,range , nil, size, nil)
        let frame = CTFramesetterCreateFrame(frameset, range, CGPath(rect: CGRect(x: 0, y: 0, width: display.width, height: display.height), transform: nil), nil)
        let deltaX = constaint.width - display.width;
        let deltaY = constaint.height - display.height;
        let drawFrame =  CGRect(x: constaint.minX + deltaX * alignX, y: constaint.minY + deltaY * AlignY, width: display.width, height: display.height)
        self.drawFrame(frame: frame, rect:drawFrame)
    }
    public func drawString(string:CFAttributedString,point:CGPoint){
        self.drawString(string: string, constaint: CGRect(origin: point, size: CGSize(width: CGFloat.infinity, height: .infinity)))
    }
    public static func size(string:CFAttributedString,transform:CGAffineTransform)->CGSize{
        let frameset = CTFramesetterCreateWithAttributedString(string)
        let range = CFRange(location: 0, length: CFAttributedStringGetLength(string))
        let display = CTFramesetterSuggestFrameSizeWithConstraints(frameset,range , nil, CGSize(width: CGFloat.infinity, height: .infinity), nil);
        return display.applying(transform);
    }
    public var image:CGImage?{
        let data:CFMutableData = CFDataCreateMutable(kCFAllocatorDefault, 0)
        guard let des = self.insertImageDestination(data: data) else { return nil }
        guard let img = self.context.makeImage() else { return nil }
        CGImageDestinationAddImage(des,img, [kCGImageDestinationLossyCompressionQuality:0.8] as CFDictionary)
        CGImageDestinationFinalize(des)
        guard let source = CGImageSourceCreateWithData(data, nil) else { return nil }
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        
        return image
    }
    
    public func insertImageDestination(data:CFMutableData)->CGImageDestination?{
        if #available(iOS 14.0, *) {
            
            return CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)
        } else {
            return CGImageDestinationCreateWithData(data, kUTTypePNG as CFString, 1, nil)
        }
    }
    public func createLayer(size:CGSize)->CGLayer?{
        let layer = CGLayer(self.context, size: CGSize(width: size.width * self.scale, height: size.height * self.scale), auxiliaryInfo: nil)
        layer?.context?.scaleBy(x: self.scale, y: self.scale)
        return layer
    }
    public func imageSize(image:CGImage)->CGSize{
        return CGSize(width: CGFloat(image.width) / self.scale, height: CGFloat(image.height) / self.scale)
    }
    public func clean(){
        self.context.clear(CGRect(x: 0, y: 0, width: self.context.width, height: self.context.height))
    }
}


public protocol RenderContent{
    func render(renderCtx:RenderContext,rect:CGRect)
}

public struct RenderGradient:RenderContent{
    public func render(renderCtx: RenderContext,rect:CGRect) {
        let point1 = CGPoint(x: rect.minX + self.relatePoint1.x, y: rect.minY + self.relatePoint1.y)
        let point2 = CGPoint(x: rect.minX + self.relatePoint2.x, y: rect.minY + self.relatePoint2.y)
        guard let gra = self.gradient else { return }
        renderCtx.context.drawLinearGradient(gra, start: point1, end: point2, options: [.drawsAfterEndLocation,.drawsBeforeStartLocation])
    }
    public var colors:[CGColor]
    public var location:[CGFloat]
    
    public var relatePoint1:CGPoint
    public var relatePoint2:CGPoint
    
    public var gradient:CGGradient?{
        CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: self.colors as CFArray, locations: self.location)
    }
    public init(colors:[CGColor],location:[CGFloat],relatePoint1:CGPoint,relatePoint2:CGPoint){
        self.colors = colors
        self.location = location
        self.relatePoint1 = relatePoint1
        self.relatePoint2 = relatePoint2
    }
}

public struct RenderImage:RenderContent{
    public func render(renderCtx: RenderContext, rect: CGRect) {
        renderCtx.drawScaleImage(image: self.image, rect: rect, mode: self.mode)
    }
    
    public var mode:DrawImageMode
    public var image:CGImage
    public init(image:CGImage,mode:DrawImageMode){
        self.image = image
        self.mode = mode
    }
}
