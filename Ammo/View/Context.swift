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

public enum DrawImageMode{
    case fill
    case fillScale
    case fillScaleClip
    case scale
}

public struct RenderContext{
    public private(set) var context:CGContext
    public init(size:CGSize,scale:CGFloat){
        self.context = RenderContext.context(size: size, scale: scale)!
        self.context.scaleBy(x: scale, y: -scale)
        self.context.translateBy(x: 0, y: -size.height)
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
        print(rect)
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
    public func drawString(string:CFAttributedString,constaint:CGRect){
        var size = constaint.size
        size.width = constaint.size.width < 0 ? CGFloat.infinity : constaint.size.width
        size.height = constaint.size.height < 0 ? CGFloat.infinity : constaint.size.height
        let frameset = CTFramesetterCreateWithAttributedString(string)
        let range = CFRange(location: 0, length: CFAttributedStringGetLength(string))
        let display = CTFramesetterSuggestFrameSizeWithConstraints(frameset,range , nil, size, nil)
        let frame = CTFramesetterCreateFrame(frameset, range, CGPath(rect: CGRect(x: 0, y: 0, width: display.width, height: display.height), transform: nil), nil)
        let drawFrame =  CGRect(x: constaint.minX, y: constaint.minY, width: display.width, height: display.height)
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
        return self.context.makeImage()
    }
}

public class IconFont{
    let scale:CGFloat = 3
    public var data:Data
    public var descriptor:[CTFontDescriptor]
    public init(fontUrl:URL) throws{
        self.data = try Data(contentsOf: fontUrl)
        guard let fd = CTFontManagerCreateFontDescriptorsFromData(self.data as CFData) as? [CTFontDescriptor] else {
            throw NSError(domain: "get font error", code: 1)
        }
        self.descriptor = fd
    }
    public convenience init() throws {
        guard let u = Bundle.main.url(forResource: "iconfont", withExtension: "ttf") else { throw NSError(domain: "no iconfont", code: 0) }
        try self.init(fontUrl: u)
    }
    public func icon(charactor:String,size:CGFloat,color:CGColor)throws ->CGImage{
        guard let char = charactor.first else { throw NSError(domain: "no char", code: 2)}
        return try self.charIcon(chars: char.utf16.map({$0}), size: size,color: color)
    }
    public func attribute(charactor:String,size:CGFloat,color:UIColor) ->NSAttributedString?{
        guard let img = self.uiIcon(charactor: charactor, size: size, color: color) else { return nil }
        let att = NSTextAttachment()
        att.image = img
        att.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        return NSAttributedString(attachment: att)
    }
    public func uiIcon(charactor:String,size:CGFloat,color:UIColor)->UIImage?{
        do{
            return UIImage(cgImage:try self.icon(charactor: charactor, size: size, color: color.cgColor),scale: self.scale,orientation: .up)
        }catch{
            return nil
        }
    }
    private func font(size:CGFloat,index:Int = 0)->CTFont{
        return CTFontCreateWithFontDescriptor(self.descriptor[index], size, nil)
    }
    public func charIcon(chars:[UInt16],size:CGFloat,color:CGColor)throws ->CGImage{
        let charactor = UnsafeMutablePointer<UInt16>.allocate(capacity: chars.count)
        defer{
            charactor.deallocate()
        }
        charactor.assign(from: chars, count: chars.count)
        let font = self.font(size: size * scale)
        var g:CGGlyph = 0
        guard CTFontGetGlyphsForCharacters(font, charactor, &g, chars.count) else { throw NSError(domain: "get glyphs error", code: 4)}
        guard let path = CTFontCreatePathForGlyph(font, g, nil) else { throw NSError(domain: "create path error", code: 0)}
        let rect = path.boundingBoxOfPath
        guard let ctx = RenderContext.context(size:rect.size, scale: 1) else { throw NSError(domain: "ctx error", code: 5)}
        ctx.translateBy(x:-rect.origin.x, y: -rect.origin.y)
        ctx.setFillColor(color)
        ctx.addPath(path)
        ctx.fillPath()
        guard let imag = ctx.makeImage() else { throw NSError(domain: "create image error", code: 6)}
        return imag
    }
}
