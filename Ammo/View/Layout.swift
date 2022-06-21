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

public struct ValueNumber:ExpressibleByFloatLiteral,LayoutValue {
    public func valueInContext(value: Double)->Double {
        switch(mode){
        case .pt:
            return self.value
        case .per:
            return self.value * value
        }
    }
    
    
    public typealias FloatLiteralType = Double
    
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
}
public struct ValueRange:LayoutValue,ExpressibleByFloatLiteral{
    
    public init(floatLiteral value: Double) {
        self.init(value: ValueNumber(floatLiteral: value))
    }
    
    public init(value:ValueNumber,min:ValueNumber? = nil,max:ValueNumber? = nil){
        self.value = value
        self.min = min
        self.max = max
    }
    
    public typealias FloatLiteralType = Double

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


public class Item {
    public var width:ValueRange?
    public var height:ValueRange?
    
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
    
    public func layout(){
        if self.resultFrame == nil{
            self.resultFrame = CGRect(origin: .zero, size: self.contentSize)
        }
    }
    public func relayout(){
        self.resultFrame = nil
        for i in self.children{
            i.relayout()
        }
        self.layout()
    }
    
    public var grow:Double
    
    public var shrink:Double
    
    public var parent:Item?
    
    public var children:[Item]
    
    public init(items:[Item],width:ValueRange? = nil,height:ValueRange? = nil,grow:Double = 0,shrink:Double = 0){
        self.children = items
        self.width = width
        self.height = height
        self.grow = grow
        self.shrink = shrink
        for i in items{
            i.parent = self
        }
    }
    public func config(block:(Self)->Void)->Self{
        block(self)
        return self
    }
}

public class Stack:Item {
    
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
        switch(self.axis){
        case .vertical:
            let delta = self.contentSize.height - self.childContentSize.height
            return self.resizeV(delta: delta)
        case .horizental:
            let delta = self.contentSize.width - self.childContentSize.width
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
    public var sumGrow:Double{
        self.children.reduce(0) { partialResult, i in
            partialResult + i.grow
        }
    }
    
    public var sumShrink:Double{
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
        for i in self.children{
            switch(self.align){
            case .start:
                i.resultFrame?.origin.y = 0
                break
            case .center:
                let ex = (self.contentSize.height - (i.resultFrame?.height ?? 0)) / 2
                i.resultFrame?.origin.y = ex
            case .end:
                let ex = (self.contentSize.height - (i.resultFrame?.height ?? 0))
                i.resultFrame?.origin.y = ex
            case .fill:
                i.resultFrame?.origin.y = 0
                break
            }
        }
    }
    
    func layoutVCross(){
        for i in self.children{
            switch(self.align){
            case .start:
                i.resultFrame?.origin.x = 0
                break
            case .center:
                let ex = (self.contentSize.height - (i.resultFrame?.height ?? 0)) / 2
                i.resultFrame?.origin.x = ex
            case .end:
                let ex = (self.contentSize.height - (i.resultFrame?.height ?? 0))
                i.resultFrame?.origin.x = ex
            case .fill:
                i.resultFrame?.origin.x = 0
                break
            }
        }
    }
    func resizeH(delta:CGFloat)->CGFloat{
        var result:Bool = false
        if delta > 0{
            for i in self.children{
                if (i.resultFrame == nil){
                    i.resultFrame = .zero
                }
                if i.grow != 0{
                    let r = i.resultFrame!.size.height + (delta * i.grow / sumGrow)
                    i.resultFrame?.size.height = i.height?.valueInContext(value: r) ?? r
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
                    i.resultFrame?.size.height = i.height?.valueInContext(value: r) ?? r
                    i.layout()
                    result = true
                }
                
            }
        }
        return result ? 0 : delta
    }
    
    func resizeV(delta:CGFloat)->CGFloat{
        var result:Bool = false
        if delta > 0{
            for i in self.children{
                if (i.resultFrame == nil){
                    i.resultFrame = .zero
                }
                if i.grow != 0{
                    let r = i.resultFrame!.size.width + (delta * i.grow / sumGrow)
                    i.resultFrame?.size.width = i.width?.valueInContext(value: r) ?? r
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
                    i.resultFrame?.size.width = i.width?.valueInContext(value: r) ?? r
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
                i.resultFrame?.size.height = self.contentSize.height
                i.layout()
            }
        }
    }
    
    func resizeCrossV(){
        for i in children{
            if i.width == nil && self.align == .fill{
                i.resultFrame?.size.width = self.contentSize.width
                i.layout()
            }
        }
    }
}
