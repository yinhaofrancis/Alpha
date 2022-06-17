//
//  Layout.swift
//  Ammo
//
//  Created by hao yin on 2022/6/17.
//

import Foundation
import QuartzCore

public enum Dimension{
    case value(v:Double)
    case percent(p:Double)
    public func valueInContext(relateValue:Double)->Double{
        switch(self){
            
        case .value(v: let v):
            return v
        case .percent(p: let p):
            return relateValue * p
        }
    }
}

public struct RangeDimension:ExpressibleByFloatLiteral,ExpressibleByIntegerLiteral{
    
    
    public init(floatLiteral value: Double) {
        self.min = nil
        self.max = nil
        self.value = .value(v: value)
    }
    public init(integerLiteral value: Int) {
        self.min = nil
        self.max = nil
        self.value = .value(v: Double(value))
    }
    
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    
    public var min:Dimension?
    public var max:Dimension?
    public var value:Dimension
    
    public init(value:Dimension,max:Dimension? = nil,min:Dimension? = nil){
        self.min = min
        self.max = max
        self.value = value
    }
    public func valueInContextLimitValue(relateValue:Double,constant:Double)->Double{
        var temp = constant
        if let max = self.max {
            let r = max.valueInContext(relateValue: relateValue)
            if temp > r{
                temp = r
            }
        }
        
        if let min = self.min {
            let r = min.valueInContext(relateValue: relateValue)
            if temp < r{
                temp = r
            }
        }
        return temp
    }
    
    public func valueInContext(relateValue:Double)->Double{
        let v = self.value.valueInContext(relateValue: relateValue)
        return self.valueInContextLimitValue(relateValue: relateValue, constant: v)
    }
}

public class Item{
    public var x:Dimension?
    public var y:Dimension?
    public var width:RangeDimension?
    public var height:RangeDimension?
    public var flex:Double = 0
    public var parent:Item?
    public var children:[Item] = []
    
    
    public var layoutFrame:CGRect = .zero
    
    var defineContentSize:CGSize = .zero
    public var contentSize:CGSize{
        CGSize(width: self.width?.valueInContext(relateValue: Double(self.parent?.layoutFrame.width ?? 0)) ?? self.defineContentSize.width,
               height: self.height?.valueInContext(relateValue: Double(self.parent?.layoutFrame.height ?? 0)) ?? self.defineContentSize.height)
    }
    public var layoutLocation:CGPoint{
        let x = self.x?.valueInContext(relateValue: Double(self.parent?.layoutFrame.width ?? 0)) ?? 0
        let y = self.y?.valueInContext(relateValue: Double(self.parent?.layoutFrame.height ?? 0)) ?? 0
        return CGPoint(x: x, y: y)
    }
    public init() {}
    public func layout(){
        self.children.forEach { i in
            i.layout()
        }
        self.layoutFrame = CGRect(origin: self.layoutLocation, size: self.contentSize)
    }
}
extension Item{
    public func setDefaultContentSize(size:CGSize)->Self{
        self.defineContentSize = size
        return self
    }
    
    public func setChildren(items:[Item])->Self{
        self.children = items
        return self
    }
    public func config(item:(Self)->Void)->Self{
        item(self)
        return self
    }
}

public class Frame:Item{
    public override var contentSize: CGSize{
        let w = self.children.reduce(0) { partialResult, i in
            max(partialResult, i.layoutFrame.maxX)
        }
        let h = self.children.reduce(0) { partialResult, i in
            max(partialResult, i.layoutFrame.maxY)
        }
        self.defineContentSize = CGSize(width: w, height: h)
        return super.contentSize
    }
}
// 10 + 10 + 10 + x =
public class Stack:Item{

    public enum Direction{
        case vertical
        case horizental
    }
    
    public enum Justify{
        case start
        case center
        case end
        case between
        case evenly
        case arround
    }
    public enum Align{
        case start
        case center
        case end
        case fill
    }
    
    public var direction:Direction = .horizental
    public var justify:Justify = .start
    public var align:Align = .start
    
    var innerContentSize:CGSize{
        switch(self.direction){
            
        case .vertical:
            let h = self.children.reduce(0) { partialResult, i in
                partialResult + i.layoutFrame.height
            }
            let w = children.reduce(0) { partialResult, i in
                max(partialResult, i.layoutFrame.width)
            }
            return CGSize(width: w, height: h)
        case .horizental:
            let w = self.children.reduce(0) { partialResult, i in
                partialResult + i.layoutFrame.width
            }
            let h = children.reduce(0) { partialResult, i in
                max(partialResult, i.layoutFrame.height)
            }
            return CGSize(width: w, height: h)
        }
    }
    public override var contentSize: CGSize{
        self.defineContentSize = innerContentSize
        return super.contentSize
    }
    public override func layout() {
        super.layout()
        self.fullfillSize()
    }
    private func fullfillSize(){
        switch(self.direction){
            
        case .vertical:
            let deltaY = self.layoutFrame.height - self.contentSize.height
        case .horizental:
            let deltaX = self.layoutFrame.width - self.contentSize.width
        }
    }
    private func next(after:Item)->CGPoint{
        switch(self.direction){
            
        case .vertical:
            return CGPoint(x: 0, y: after.layoutFrame.maxY)
        case .horizental:
            return CGPoint(x: after.layoutFrame.maxX, y: 0)
        }
    }
}

