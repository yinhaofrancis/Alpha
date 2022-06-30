//
//  Layout.swift
//  Ammo
//
//  Created by hao yin on 2022/6/17.
//

import Foundation
import QuartzCore

public protocol LayoutValue{
    func valueInContext(value:Double)->Double
}

public struct ValueNumber:ExpressibleByFloatLiteral,ExpressibleByIntegerLiteral,LayoutValue {
    public func valueInContext(value: Double)->Double {
        switch(mode){
        case .pt:
            return self.value
        case .per:
            return self.value * value
        }
    }
    
    
    public typealias FloatLiteralType = Double
    
    public typealias IntegerLiteralType = Int
    
    public var value:Double
    
    public var mode:ValueMode
    
    public enum ValueMode{
        case pt
        case per
    }
    
    public init(value:FloatLiteralType,mode:ValueMode){
        self.value = value
        self.mode = mode
    }
    
    public init(floatLiteral value: Double) {
        self.init(value: value, mode: .pt)
    }
    public init(integerLiteral value: Int) {
        self.init(floatLiteral: Double(value))
    }
}
public struct ValueRange:LayoutValue,ExpressibleByFloatLiteral,ExpressibleByIntegerLiteral{
    
    public typealias FloatLiteralType = Double
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.init(floatLiteral: Double(value))
    }
    public init(floatLiteral value: Double) {
        self.init(value: ValueNumber(floatLiteral: value))
    }
    
    public init(value:ValueNumber,min:ValueNumber? = nil,max:ValueNumber? = nil){
        self.value = value
        self.min = min
        self.max = max
    }
    
    

    public func valueInContext(value: Double) -> Double {
        var re:Double = self.value.valueInContext(value: value)
        if let m = self.max{
            re = Swift.min(m.valueInContext(value: value), re)
        }
        if let m = self.min{
            re = Swift.max(m.valueInContext(value: value), re)
        }
        return re
    }
    
    
    public var min:ValueNumber?
    
    public var max:ValueNumber?
    
    public var value:ValueNumber
    
}
public class Item:CustomDebugStringConvertible{
    public var debugDescription: String{
        return "\(Self.self),\(String(describing: self.resultFrame))"
    }
    
    public var width:ValueRange?
    
    public var height:ValueRange?
    
    public var grow:Double
    
    public var shrink:Double
    
    public var parent:Item?
    
    public var contentSize:CGSize {
        let w = CGFloat(width?.valueInContext(value: 0) ?? self.childContentSize.width)
        let h = CGFloat(height?.valueInContext(value: 0) ?? self.childContentSize.height)
        return CGSize(width: w, height: h)
    }
    
    public var childContentSize:CGSize{
        return .zero
    }
    
    public var resultFrame:CGRect?
    
    public var resultSize:CGSize{
        return self.resultFrame?.size ?? .zero
    }
    
    public func relayout() {}
    
    public func layout(){
        if self.resultFrame == nil{
            self.resultFrame = CGRect(origin: .zero, size: self.contentSize)
        }
    }
    public init(width:ValueRange? = nil,height:ValueRange? = nil,grow:Double = 0,shrink:Double = 0){
        self.width = width
        self.height = height
        self.grow = grow
        self.shrink = shrink
    }
}
extension Item{
    public var windowFrame:CGRect{
        var parent = self.parent
        var rect = self.resultFrame ?? .zero
        while(parent != nil){
            rect.origin.x += parent?.resultFrame?.origin.x ?? 0
            rect.origin.y += parent?.resultFrame?.origin.y ?? 0
            parent = parent?.parent
        }
        return rect
    }
}

public protocol FillContentProtocol:AnyObject{
    
    func constaintSize(size:CGSize)->CGSize
}
public class FillItem:Item{
    
    public weak var fillContent:FillContentProtocol?
    
    public override var childContentSize: CGSize{
        if resultFrame == nil{
            var cs = self.contentSize
            cs.width = self.width == nil ? CGFloat.infinity : cs.width
            cs.height = self.height == nil ? CGFloat.infinity : cs.height
            return self.fillContent?.constaintSize(size: cs) ?? .zero
        }else{
            return self.fillContent?.constaintSize(size: self.resultSize) ?? .zero
        }
        
    }
    
    
}
public class Resize:Item{
    public enum Mode{
        case scale
        case scaleToFill
        case scaleToFit
    }
    public var content:Item
    public var mode:Mode
    public init(content:Item, width: ValueRange, height: ValueRange,mode:Mode,grow: Double = 0, shrink: Double = 0) {
        self.content = content
        self.mode = mode
        super.init(width: width, height: height, grow: grow, shrink: shrink)
    }
    public override func layout() {
        super.layout()
        content.layout()
        if content.resultSize.width == 0 || content.resultSize.height == 0{
            return
        }
        switch(self.mode){
        case .scale:
            self.content.resultFrame = CGRect(x: 0, y: 0, width:self.resultSize.width , height: self.resultSize.height)
            content.layout()
            break;
        case .scaleToFit:
            let ratio = min(self.resultSize.width / content.resultSize.width, self.resultSize.height / content.resultSize.height)
            let size = CGSize(width: content.resultSize.width * ratio, height: content.resultSize.height * ratio)
            let x = (self.resultSize.width - size.width) / 2
            let y = (self.resultSize.height - size.height) / 2
            content.resultFrame = CGRect(x: x, y: y, width: size.width, height: size.height)
            content.layout()
            break
        case .scaleToFill:
            let ratio = max(self.resultSize.width / content.resultSize.width, self.resultSize.height / content.resultSize.height)
            let size = CGSize(width: content.resultSize.width * ratio, height: content.resultSize.height * ratio)
            let x = (self.resultSize.width - size.width) / 2
            let y = (self.resultSize.height - size.height) / 2
            content.resultFrame = CGRect(x: x, y: y, width: size.width, height: size.height)
            content.layout()
            break
        }
    }
    public override var debugDescription: String{
        return super.debugDescription + "{\(content.debugDescription)}"
    }
}
public class Container:Item {
    
    public override var debugDescription: String{
        return super.debugDescription + "\n\(self.children)"
    }

    public override func relayout(){
        super.relayout()
        self.resultFrame = nil
        for i in self.children{
            i.relayout()
        }
        self.layout()
    }
    
    public var children:[Item]
    
    public init(items:[Item],width:ValueRange? = nil,height:ValueRange? = nil,grow:Double = 0,shrink:Double = 0){
        self.children = items
        super.init(width: width, height: height, grow: grow, shrink: shrink)
    }
}
public struct Edge:Equatable{
    public var left:Double
    public var right:Double
    public var top:Double
    public var bottom:Double
    public init(left:Double,right:Double,top:Double,bottom:Double){
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
    public static let zero:Edge = Edge(left: 0, right: 0, top: 0, bottom: 0)
}
public class Align:Item{
    public var content:Item
    public var alignX:Double
    public var alignY:Double
    public init(content:Item,
                width: ValueRange,
                height: ValueRange,
                alignX:Double,
                alignY:Double,
                grow: Double = 0,
                shrink: Double = 0) {
        self.alignX = alignX
        self.alignY = alignY
        self.content = content
        super.init(width: width, height: height, grow: grow, shrink: shrink)
        self.content.parent = self
        
    }
    public static func center(content:Item,
                              width: ValueRange,
                              height: ValueRange,
                              grow: Double = 0,
                              shrink: Double = 0)->Align{
        return Align(content: content, width: width, height: height, alignX: 0.5, alignY: 0.5, grow: grow, shrink: shrink)
    }
    public override func layout() {
        if self.resultFrame == nil{
            super.layout()
            content.layout()
        }
        let x = (self.resultSize.width - content.resultSize.width) * alignX
        let y = (self.resultSize.height - content.resultSize.height) * alignX
        content.resultFrame?.origin.y = y
        content.resultFrame?.origin.x = x
    }
}
public class Padding:Item{
    public var content:Item
    public var pading:Edge
    public init(content:Item,padding:Edge = .zero,grow:Double = 0,shrink:Double = 0){
        self.content = content
        self.pading = padding
        super.init(width: nil, height: nil, grow: grow, shrink: shrink)
        self.content.parent = self
    }
    public override func layout() {
        
        content.layout()
        if self.resultFrame == nil{
            content.resultFrame = CGRect(x: self.pading.left, y: self.pading.top, width: content.resultSize.width, height: content.resultSize.height)
            self.resultFrame = CGRect(origin: .zero, size: CGSize(width: content.resultSize.width + self.pading.left + self.pading.right, height: content.resultSize.height + self.pading.top + self.pading.bottom))
        }else{
            
            content.resultFrame = Padding.paddingRect(content: content.resultSize , edge: self.pading, container: self.resultSize)
        }
        
    }
    public static func paddingRect(content:CGSize,edge:Edge,container:CGSize)->CGRect{
        var result = CGRect.zero
        if edge.left == 0 && edge.right == 0{
            result.origin.x = (container.width - content.width) / 2
            result.size.width = content.width
        }else if edge.left == 0{
            result.origin.x = container.width - content.width
            result.size.width = content.width
        }else if edge.right == 0{
            result.origin.x = edge.left
            result.size.width = content.width
        }else{
            result.origin.x = edge.left
            result.size.width = container.width - edge.left - edge.right
        }
        
        if edge.top == 0 && edge.bottom == 0{
            result.origin.y = (container.height - content.height) / 2
            result.size.height = content.height
        }else if edge.top == 0{
            result.origin.y = container.height - content.height
            result.size.height = content.height
        }else if edge.bottom == 0{
            result.origin.y = edge.top
            result.size.height = content.height
        }else{
            result.origin.y = edge.top
            result.size.height = container.height - edge.left - edge.right
        }
        return result
    }
    public override var debugDescription: String{
        return super.debugDescription + "{\(content.debugDescription)}"
    }
}
public class Stack:Container{
    
    public enum Axis{
        case vertical
        case horizental
    }
    
    public enum Justify{
        case start
        case center
        case end
        case around
        case evenly
        case between
    }
    
    public enum Align{
        case start
        case center
        case end
        case fill
    }
    
    public var axis:Axis = .horizental
    
    public var justify:Justify = .start
    
    public var align:Align = .start
    
    public override func layout() {
        for i in self.children{
            i.parent = self
            i.layout()
        }
        super.layout()
        let delta = self.resize()
        self.resizeCross()
        self.layoutLocation(extra: delta)
    }
    public override var childContentSize:CGSize{
        switch(self.axis){
            
        case .vertical:
            return self.children.reduce(CGSize.zero) { partialResult, i in
                let h = partialResult.height + i.resultSize.height
                let w = max(partialResult.width, i.resultSize.width)
                return CGSize(width: w, height: h)
            }
        case .horizental:
            return self.children.reduce(CGSize.zero) { partialResult, i in
                let w = partialResult.width + i.resultSize.width
                let h = max(partialResult.height, i.resultSize.height)
                return CGSize(width: w, height: h)
            }
        }
    }
    
    func resize()->CGFloat{
        guard let frame = self.resultFrame else { return 0 }
        switch(self.axis){
        case .vertical:
            let delta = frame.height - self.childContentSize.height
            return self.resizeV(delta: delta)
        case .horizental:
            let delta = frame.width - self.childContentSize.width
            return self.resizeH(delta: delta)
        }
    }
    func resizeCross(){
        switch(self.axis){
        case .vertical:
            self.resizeCrossV()
            break
        case .horizental:
            self.resizeCrossH()
            break
        }
    }
    var sumGrow:Double{
        self.children.reduce(0) { partialResult, i in
            partialResult + i.grow
        }
    }
    
    var sumShrink:Double{
        self.children.reduce(0) { partialResult, i in
            partialResult + i.shrink
        }
    }
    func layoutLocation(extra:CGFloat){
        switch(self.axis){
        case .vertical:
            self.layoutVAxis(extra: extra)
            self.layoutVCross()
            break
        case .horizental:
            self.layoutHAxis(extra: extra)
            self.layoutHCross()
            break
        }
    }
    func makeParam(extra:CGFloat)->(start:CGFloat,step:CGFloat){
        var start:CGFloat = 0
        var step:CGFloat = 0
        switch(self.justify){
            
        case .start:
            start = 0
            step = 0
            break
        case .center:
            start = extra / 2
            step = 0
            break
        case .end:
            start = extra / 2
            step = 0
            break
        case .around:
            start = (extra / CGFloat(2 * self.children.count))
            step = start * 2
        case .evenly:
            start = (extra / CGFloat(1 + self.children.count))
            step = start
        case .between:
            if self.children.count - 1 == 0{
                start = 0
                step = 0
            }else{
                start = (extra / CGFloat(self.children.count - 1))
                step = start
            }
            break
            
        }
        return (start,step)
    }
    func layoutHAxis(extra:CGFloat){
        let param = self.makeParam(extra: extra)
        var point = param.start
        for i in self.children{
            i.resultFrame?.origin.x = point
            point = point + param.step + (i.resultFrame?.width ?? 0)
        }
    }
    func layoutVAxis(extra:CGFloat){
        let param = self.makeParam(extra: extra)
        var point = param.start
        for i in self.children{
            i.resultFrame?.origin.y = point
            point = point + param.step + (i.resultFrame?.height ?? 0)
        }
    }
    func layoutHCross(){
        guard let frame = self.resultFrame else { return }
        for i in self.children{
            switch(self.align){
            case .start:
                i.resultFrame?.origin.y = 0
                break
            case .center:
                let ex = (frame.height - (i.resultFrame?.height ?? 0)) / 2
                i.resultFrame?.origin.y = ex
            case .end:
                let ex = (frame.height - (i.resultFrame?.height ?? 0))
                i.resultFrame?.origin.y = ex
            case .fill:
                i.resultFrame?.origin.y = 0
                break
            }
        }
    }
    
    func layoutVCross(){
        guard let frame = self.resultFrame else { return }
        for i in self.children{
            switch(self.align){
            case .start:
                i.resultFrame?.origin.x = 0
                break
            case .center:
                let ex = (frame.height - (i.resultFrame?.height ?? 0)) / 2
                i.resultFrame?.origin.x = ex
            case .end:
                let ex = (frame.height - (i.resultFrame?.height ?? 0))
                i.resultFrame?.origin.x = ex
            case .fill:
                i.resultFrame?.origin.x = 0
                break
            }
        }
    }
    func resizeV(delta:CGFloat)->CGFloat{
        var result:Bool = false
        if delta > 0{
            for i in self.children{
                if (i.resultFrame == nil){
                    i.resultFrame = .zero
                }
                if i.grow != 0{
                    let r = i.resultFrame!.size.height + (delta * i.grow / sumGrow)
                    i.resultFrame?.size.height = r
                    i.layout()
                    result = true
                }
            }
        }else if delta < 0{
            for i in self.children{
                if (i.resultFrame == nil){
                    i.resultFrame = .zero
                }
                if i.shrink != 0{
                    let r = i.resultFrame!.size.height + (delta * i.shrink / sumShrink)
                    i.resultFrame?.size.height = r
                    i.layout()
                    result = true
                }
                
            }
        }
        return result ? 0 : delta
    }
    
    func resizeH(delta:CGFloat)->CGFloat{
        var result:Bool = false
        if delta > 0{
            for i in self.children{
                if (i.resultFrame == nil){
                    i.resultFrame = .zero
                }
                if i.grow != 0{
                    let r = i.resultFrame!.size.width + (delta * i.grow / sumGrow)
                    i.resultFrame?.size.width = r
                    i.layout()
                    result = true
                }
            }
        }else if delta < 0{
            for i in self.children{
                if (i.resultFrame == nil){
                    i.resultFrame = .zero
                }
                if i.shrink != 0{
                    let r = i.resultFrame!.size.width + (delta * i.shrink / sumShrink)
                    i.resultFrame?.size.width = r
                    i.layout()
                    result = true
                }
            }
        }
        return result ? 0 : delta
    }
    
    func resizeCrossH(){
        for i in children{
            if i.height == nil && self.align == .fill{
                i.resultFrame?.size.height = (self.resultFrame?.height ?? 0)
                i.layout()
            }
        }
    }
    
    func resizeCrossV(){
        for i in children{
            if i.width == nil && self.align == .fill{
                i.resultFrame?.size.width = (self.resultFrame?.width ?? 0)
                i.layout()
            }
        }
    }
}
