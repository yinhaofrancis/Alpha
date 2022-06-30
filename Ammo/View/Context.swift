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

public struct Context{
    public private(set) var context:CGContext
    public init(size:CGSize,scale:CGFloat){
        let w = Int(size.width * scale)
        self.context = CGContext(data: nil, width:  w , height: Int(size.height * scale), bitsPerComponent: 8, bytesPerRow: 4 * w , space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        self.context.scaleBy(x: scale, y: -scale)
        self.context.translateBy(x: 0, y: -size.height)
    }
    
    public func begin(call:(Context)->Void){
        self.context.saveGState()
        call(self)
        self.context.restoreGState()
    }
    @available(iOS 13.0, *)
    public func render(_ call:@escaping (Context)->Void) async ->CGImage?{
        return await Task {
            self.syncRender(call)
        }.value
    }
    public func syncRender(_ call:(Context)->Void) ->CGImage?{
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
    public var image:CGImage?{
        return self.context.makeImage()
    }
}

public class ViewItem{

    public enum ViewScaleMode{
        case scale
        case scaleToFill
        case scaleToFit
    }
    
    public private(set) var item:Item = Item()
    public var mode:ViewScaleMode = .scaleToFit
    public var color:CGColor?
    public func draw(ctx:Context){
        guard let frame = self.item.resultFrame else { return  }
        if let c = self.color{
            ctx.context.setFillColor(c)
        }
        ctx.context.fill(frame)
    }
    public func size(constaint:CGSize)->CGSize{
        return constaint
    }
}

public class StackViewItem:ViewItem{
    public var stack:Stack
    public override var item: Item{
        get{
            return self.stack
        }
        set{
            self.stack = newValue as! Stack
        }
    }
    public init(viewItems:[ViewItem] = []){
        
        self.viewItems = viewItems
        self.stack = Stack(items: viewItems.map({$0.item}))
    }
    
    public var viewItems:[ViewItem]{
        didSet{
            self.stack.children = self.viewItems.map({$0.item})
        }
    }
    public override func draw(ctx: Context) {
        super.draw(ctx: ctx)
        for i in self.viewItems{
            i.draw(ctx: ctx)
        }
    }
}
