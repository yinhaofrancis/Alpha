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
    public var contentSize:CGSize{
        frame.size
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

public class Center:View{
    public var content:View
    public var align:CGPoint
    public static let alignCenter = CGPoint(x: 0.5, y: 0.5)
    public init(content:View,frame:CGRect,align:CGPoint = Center.alignCenter){
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

public class ViewSet:View{
    public var views:[View]
    public init(views:[View]){
        self.views = views
        super.init(frame: .zero)
    }
    public func layout(rect:CGRect){
        
    }
}

@resultBuilder
public struct ViewBuilder{
    public static func buildBlock(_ components: View...) -> ViewSet {
        return ViewSet(views: components)
    }
    public static func buildBlock(_ components: View) -> ViewSet {
        return ViewSet(views: [components])
    }
    public static func buildBlock(_ components: [View]...) -> ViewSet {
        return ViewSet(views: components.reduce(into: []) { partialResult, r in
            partialResult.append(contentsOf: r)
        })
    }
    public static func buildEither(first component: ViewSet) -> ViewSet {
        return component
    }
    public static func buildEither(second component: ViewSet) -> ViewSet {
        return component
    }
    public static func buildOptional(_ component: ViewSet?) -> ViewSet {
        return ViewSet(views: [])
    }
    public static func buildArray(_ components: [ViewSet]) -> ViewSet {
        ViewSet(views: components.map({$0.views}).flatMap({$0}))
    }
}
public enum AlignMode{
    case start
    case center
    case end
    case fill
}
public enum Axis{
    case row
    case col
}
public enum ContentMode{
    case start
    case center
    case end
    case arround
    case evenly
    case between
}
public class Stack:ViewSet{

    
    public var axis:Axis
    public var alignMode:AlignMode
    public var spacing:CGFloat
    public var contentMode:ContentMode
    
    public init(@ViewBuilder views:()->ViewSet,
                contentMode:ContentMode = .start,
                alignMode:AlignMode = .center,
                axis:Axis = .row,
                spacing:CGFloat = 0){
        self.alignMode = alignMode
        self.spacing = spacing
        self.contentMode = contentMode
        self.axis = axis
        super.init(views: views().views)
    }
    public override func draw(rect: CGRect, ctx: Context) {
        super.draw(rect: rect, ctx: ctx)
        self.layout(rect: rect)
        for i in self.views{
            i.render(ctx: ctx)
        }
    }
    public override var contentSize: CGSize{
        if self.views.count > 0{
            let w = self.views.reduce(into: 0, {$0 += $1.contentSize.width}) + CGFloat((self.views.count - 1)) * self.spacing
            let h = self.views.max(by: {$0.contentSize.height < $1.contentSize.height})?.contentSize.height ?? 0
            return CGSize(width: w, height: h)
        }else{
            return self.frame.size
        }
    }
    public override func layout(rect: CGRect) {
        switch(self.axis){
            
        case .row:
            self.layoutH(rect: rect)
        case .col:
            self.layoutV(rect: rect)
        }
    }
    public func layoutH(rect:CGRect){
        let extra = rect.width - self.contentSize.width
        var x:CGFloat = 0
        switch(self.contentMode){
            
        case .start:
            x = 0
        case .center:
            x = extra / 2
        case .end:
            x = extra
        case .arround:
            x = extra / CGFloat((self.views.count * 2))
        case .evenly:
            x = extra / CGFloat((self.views.count  + 1))
        case .between:
            if self.views.count > 1{
                x = extra / CGFloat((self.views.count  - 1))
            }
        }
        
        for i in self.views{
            switch(self.alignMode){
            case .start:
                i.frame = CGRect(x: x, y: 0, width: i.frame.width, height: i.frame.height)
            case .center:
                let y:CGFloat = rect.height - i.contentSize.height
                i.frame = CGRect(x: x, y: y / 2, width: i.frame.width, height: i.frame.height)
            case .end:
                let y:CGFloat = rect.height - i.contentSize.height
                i.frame = CGRect(x: x, y: y, width: i.frame.width, height: i.frame.height)
            case .fill:
                i.frame = CGRect(x: x, y: 0, width: i.frame.width, height: rect.height)
            }
            x += i.contentSize.width + spacing
        }
    }
    
    public func layoutV(rect:CGRect){
        var y:CGFloat = 0
        let extra = rect.height - self.contentSize.height
        switch(self.contentMode){
            
        case .start:
            y = 0
        case .center:
            y = extra / 2
        case .end:
            y = extra
        case .arround:
            y = extra / CGFloat((self.views.count * 2))
        case .evenly:
            y = extra / CGFloat((self.views.count  + 1))
        case .between:
            if self.views.count > 1{
                y = extra / CGFloat((self.views.count  - 1))
            }
        }
        for i in self.views{
            switch(self.alignMode){
            case .start:
                i.frame = CGRect(x: 0, y: y, width: i.frame.width, height: i.frame.height)
            case .center:
                let x:CGFloat = rect.width - i.contentSize.width
                i.frame = CGRect(x: x / 2, y: y, width: i.frame.width, height: i.frame.height)
            case .end:
                let x:CGFloat = rect.width - i.contentSize.width
                i.frame = CGRect(x: x, y: y, width: i.frame.width, height: i.frame.height)
            case .fill:
                i.frame = CGRect(x: 0, y: y, width: i.frame.width, height: rect.height)
            }
            y += i.contentSize.height + spacing
        }
    }
}
