//
//  IconFont.swift
//  Ammo
//
//  Created by hao yin on 2022/8/3.
//

import QuartzCore
import CoreText
import UIKit

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
    public static var shared:IconFont = try! IconFont()
    public func icon(charactor:String,size:CGFloat,color:CGColor)throws ->CGImage{
        guard let char = charactor.first else { throw NSError(domain: "no char", code: 2)}
        return try self.charIcon(chars: char.utf16.map({$0}), size: size,color: color)
    }

    public func icon(icon:Icon)throws ->CGImage{
        return try self.icon(charactor: icon.text, size: icon.size, color: icon.color.cgColor)
    }
    public func iconPath(icon:Icon)throws ->CGPath{
        guard let char = icon.text.first else { throw NSError(domain: "no char", code: 2)}
        return try self.charIconPath(chars: char.utf16.map({$0}), size: icon.size, color: icon.color.cgColor)
    }
    public func attribute(charactor:String,size:CGFloat,color:UIColor) ->NSAttributedString?{
        guard let img = self.uiIcon(charactor: charactor, size: size, color: color) else { return nil }
        let att = NSTextAttachment()
        att.image = img
        att.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        return NSAttributedString(attachment: att)
    }
    public func attribute(icon:Icon) ->NSAttributedString?{
        self.attribute(charactor: icon.text, size: icon.size, color: icon.color)
    }
    public func uiIcon(charactor:String,size:CGFloat,color:UIColor)->UIImage?{
        do{
            return UIImage(cgImage:try self.icon(charactor: charactor, size: size, color: color.cgColor),scale: self.scale,orientation: .up)
        }catch{
            return nil
        }
    }
    public func uiIcon(icon:Icon)->UIImage?{
        do{
            return UIImage(cgImage:try self.icon(icon: icon),scale: self.scale,orientation: .up)
        }catch{
            return nil
        }
    }
    private func font(size:CGFloat,index:Int = 0)->CTFont{
        return CTFontCreateWithFontDescriptor(self.descriptor[index], size, nil)
    }
    public func charIcon(chars:[UInt16],size:CGFloat,color:CGColor)throws ->CGImage{
        let path = try self.charIconPath(chars: chars, size: size, color: color)
        let rect = path.boundingBoxOfPath
        guard let ctx = RenderContext.context(size:rect.size, scale: 1) else { throw NSError(domain: "ctx error", code: 5)}
        ctx.translateBy(x:-rect.origin.x, y: -rect.origin.y)
        ctx.setFillColor(color)
        ctx.addPath(path)
        ctx.fillPath()
        guard let imag = ctx.makeImage() else { throw NSError(domain: "create image error", code: 6)}
        return imag
    }
    public func charIconPath(chars:[UInt16],size:CGFloat,color:CGColor)throws ->CGPath{
        let charactor = UnsafeMutablePointer<UInt16>.allocate(capacity: chars.count)
        defer{
            charactor.deallocate()
        }
        charactor.assign(from: chars, count: chars.count)
        let font = self.font(size: size * scale)
        var g:CGGlyph = 0
        guard CTFontGetGlyphsForCharacters(font, charactor, &g, chars.count) else { throw NSError(domain: "get glyphs error", code: 4)}
        guard let path = CTFontCreatePathForGlyph(font, g, nil) else { throw NSError(domain: "create path error", code: 0)}
        return path
    }
}

public struct Icon{
 
    public var text:String
    public var color:UIColor
    public var size:CGFloat
    
    public init(text:String, color:UIColor,size:CGFloat){
        self.text = text
        self.color = color
        self.size = size
    }
    public var image:UIImage?{
        Icon.iconfont.uiIcon(icon: self)
    }
    public var string:NSAttributedString?{
        Icon.iconfont.attribute(icon: self)
    }
    public static var iconfont:IconFont = try! IconFont()
}

extension UIImageView{
    public func loadIcon(icon:Icon,font:IconFont){
        self.image = font.uiIcon(icon: icon)
    }
}
