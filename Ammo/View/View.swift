//
//  View.swift
//  Ammo
//
//  Created by wenyang on 2022/5/26.
//

import Foundation
import QuartzCore
import UIKit



public class View{
    public func draw(rect: CGRect,ctx:Context) {
        let path = CGPath(roundedRect: rect, cornerWidth: self.radius, cornerHeight: self.radius, transform: nil)
        ctx.context.addPath(path)
        if let c = self.background{
            ctx.context.setFillColor(c)
        }
        if let sc = self.shadowColor{
            ctx.context.setShadow(offset: self.shadowOffset, blur: self.shadowRadius, color: sc)
        }
        ctx.context.fillPath()
    }
    
    public func size(constaint: CGSize) -> CGSize {
        constaint
    }
    
    public var frame: CGRect
    
    public var background:CGColor?
    
    public var radius:CGFloat = 0
    
    public var shadowColor:CGColor?
    
    public var shadowRadius:CGFloat = 0
    
    public var shadowOffset:CGSize = .zero
    
    public init(frame:CGRect){
        self.frame = frame
    }
    public func set(_ call:(Self)->Void)->Self{
        call(self)
        return self
    }
}
extension View{
    public func render(ctx:Context){
        ctx.begin { c in
            c.context.translateBy(x: self.frame.minX, y: self.frame.minY)
            c.context.beginTransparencyLayer(auxiliaryInfo: nil)
            self.draw(rect: CGRect(origin: .zero, size: self.frame.size), ctx: ctx)
            c.context.endTransparencyLayer()
        }
    }
}

public class Align:View{
    public var content:View
    public var align:CGPoint
    public static let alignCenter = CGPoint(x: 0.5, y: 0.5)
    public init(content:View,frame:CGRect,align:CGPoint = Align.alignCenter){
        self.content = content
        self.align = align
        super.init(frame: frame)
    }
    public override func draw(rect: CGRect, ctx: Context) {
        super.draw(rect: rect, ctx: ctx)
        let deltax = (self.frame.width - content.frame.width) * align.x
        let deltay = (self.frame.height - content.frame.height) * align.y
        content.frame.origin.x = deltax
        content.frame.origin.y = deltay
        self.content.render(ctx: ctx)
    }
}
