//
//  LayoutItem.swift
//  Ammo
//
//  Created by hao yin on 2022/7/7.
//

import Foundation
import QuartzCore

public enum ValueMode{
    case percentRelateParent
    case absoluteValue
}

public struct Value{
    public var constant:CGFloat
    public var mode:ValueMode
    public func realValue(parent:CGFloat)->CGFloat{
        switch(self.mode){
            
        case .percentRelateParent:
            return parent * constant
        case .absoluteValue:
            return constant
        }
    }
}
public enum Direction{
    case horizental
    case vertical
}
public protocol LayoutContent:AnyObject{
    func fitSize(constaint:CGSize)->CGSize
}

public enum Justify{
    case start
    case center
    case end
    case between
    case around
    case evenly
}
public enum Align{
    case start
    case center
    case end
    case fill
}

public class Node{
    
    // 布局定义 当设置contentsize时width,height为contentSize 的 约束
    public weak var layoutContent:LayoutContent?
    
    public var width:Value?
    public var direction:Direction = .horizental
    public var defineWidth:CGFloat?{
        let relate = self.parent?.resultFrame.width
        return self.width?.realValue(parent: relate ?? 0)
    }
    public var height:Value?
    public var defineHeight:CGFloat?{
        let relate = self.parent?.resultFrame.height
        return self.height?.realValue(parent: relate ?? 0)
    }

    public var crossDefineSize:CGFloat?{
        guard let p = self.parent else { return nil }
        var value:CGFloat?
        switch(p.direction){
            
        case .horizental:
            value = self.defineHeight
            break
        case .vertical:
            value = self.defineWidth
            break
        }
        if let v = value{
            return v
        }else{
            return self.crossContentSize
        }
    }
    public var axisDefineSize:CGFloat?{
        guard let p = self.parent else { return nil }
        var value:CGFloat?
        switch(p.direction){
            
        case .horizental:
            value = self.defineWidth
            break
        case .vertical:
            value = self.defineHeight
            break
        }
        if let v = value{
            return v
        }else{
            return self.axisContentSize
        }
    }
    public var crossContentSize:CGFloat?{
        if self.children.count > 0{
            return self.childCrossSize
        }else{
            if let c = self.layoutContent{
                let size = c.fitSize(constaint: self.resultFrame.size)
                guard let p = parent else { return nil }
                switch(p.direction){
                case .horizental:
                    return size.width
                case .vertical:
                    return size.height
                }
            }
            return nil
        }
    }
    public var axisContentSize:CGFloat?{
        if self.children.count > 0{
            return self.childAxisSize
        }else{
            if let c = self.layoutContent{
                guard let p = parent else { return nil }
                let dsize = CGSize(width: self.defineWidth ?? -1, height: self.defineHeight ?? -1)
                let size = c.fitSize(constaint: dsize)
                switch(p.direction){
                case .horizental:
                    return size.height < 0 ? nil : size.height
                case .vertical:
                    return size.width < 0 ? nil : size.width
                }
            }
            return nil
        }
    }
    //resize 指数
    public var grows:CGFloat = 0
    public var shrink:CGFloat = 0
    
    public var align:Align = .start
    public var justify:Justify = .start
    
    // 布局结果
    public var resultFrame:CGRect = .zero
    public var crossSize:CGFloat{
        get{
            guard let p = self.parent else { return 0 }
            switch(p.direction){
                
            case .horizental:
                return self.resultFrame.height
            case .vertical:
                return self.resultFrame.width
            }
        }
        set{
            guard let p = self.parent else { return }
            var frame = self.resultFrame
            switch(p.direction){
                
            case .horizental:
                frame.size.height = newValue
                break
            case .vertical:
                frame.size.width = newValue
                break
            }
            self.resultFrame = frame
        }
    }
    public var axisSize:CGFloat{
        get{
            guard let p = self.parent else { return 0 }
            switch(p.direction){
                
            case .horizental:
                return self.resultFrame.width
            case .vertical:
                return self.resultFrame.height
            }
        }
        set{
            guard let p = self.parent else { return }
            var frame = self.resultFrame
            switch(p.direction){
                
            case .horizental:
                frame.size.width = newValue
                break
            case .vertical:
                frame.size.height = newValue
                break
            }
            self.resultFrame = frame
        }
    }
    
    public var crossLocation:CGFloat{
        get{
            guard let p = self.parent else { return 0 }
            switch(p.direction){
                
            case .horizental:
                return self.resultFrame.origin.y
            case .vertical:
                return self.resultFrame.origin.x
            }
        }
        set{
            guard let p = self.parent else { return }
            var frame = self.resultFrame
            switch(p.direction){
                
            case .horizental:
                frame.origin.y = newValue
                break
            case .vertical:
                frame.origin.x = newValue
                break
            }
            self.resultFrame = frame
        }
    }
    public var axisLocation:CGFloat{
        get{
            guard let p = self.parent else { return 0 }
            switch(p.direction){
                
            case .horizental:
                return self.resultFrame.origin.x
            case .vertical:
                return self.resultFrame.origin.y
            }
        }
        set{
            guard let p = self.parent else { return }
            var frame = self.resultFrame
            switch(p.direction){
                
            case .horizental:
                frame.origin.x = newValue
                break
            case .vertical:
                frame.origin.y = newValue
                break
            }
            self.resultFrame = frame
        }
    }
    public var crossAsParentSize:CGFloat{
        get{
            switch(self.direction){
                
            case .horizental:
                return self.resultFrame.height
            case .vertical:
                return self.resultFrame.width
            }
        }
    
    }
    public var axisAsParentSize:CGFloat{
        get{
            switch(self.direction){
                
            case .horizental:
                return self.resultFrame.width
            case .vertical:
                return self.resultFrame.height
            }
        }
    }
    public var parent:Node?
    
    
    
    // 作为集合时
    // 子节点不可以影响父节点，父节点可以影响子节点
    public var children:[Node] = []{
        didSet{
            self.children.forEach { n in
                n.parent = self
            }
        }
    }
    
    //子节点轴向尺寸
    public var childAxisSize:CGFloat{
        return self.children.reduce(into: CGFloat.zero) { partialResult, i in
            partialResult += i.axisSize
        }
    }
    //子节点垂直尺寸
    public var childCrossSize:CGFloat{
        return self.children.reduce(into: CGFloat.zero) { partialResult, i in
            partialResult += i.crossSize
        }
    }
    public var sumGrows:CGFloat{
        self.children.reduce(into: 0) { partialResult, i in
            partialResult += i.grows
        }
    }
    public var sumShrink:CGFloat{
        self.children.reduce(into: 0) { partialResult, i in
            partialResult += i.shrink
        }
    }
    public var extraSize:CGFloat{
        self.axisAsParentSize - childAxisSize
    }
    private func selfSize(){
        for  i in self.children{
            i.selfSize()
        }
        if self.parent != nil{
            self.crossSize = self.crossDefineSize ?? 0
            self.axisSize = self.axisDefineSize ?? 0
        }else{
            self.resultFrame.size.width = self.defineWidth ?? 0
            self.resultFrame.size.height = self.defineHeight ?? 0
        }
    }
    
    
    private func resize(){
        let extra = self.extraSize
        
        if extra > 0{
            let sumg = self.sumGrows
            self.children.filter { i in
                i.grows > 0
            }.forEach { i in
                i.axisSize += (i.grows / sumg * extra)
            }
        }else if extra < 0{
            let sumg = self.sumShrink
            self.children.filter { i in
                i.shrink > 0
            }.forEach { i in
                i.axisSize += (i.shrink / sumg * extra)
            }
        }
        if self.align == .fill{
            self.children.forEach { i in
                i.crossSize = self.crossAsParentSize
            }
        }
    }
    private func layoutAxis(){
        let extra = self.extraSize
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
            start = extra
            step = 0
            break
        case .between:
            start = 0
            if self.children.count > 1{
                step = extra / CGFloat(self.children.count) - 1
            }
            break
        case .around:
            start = extra / CGFloat(self.children.count * 2)
            step = start * 2
            break
        case .evenly:
            start = extra / CGFloat(self.children.count + 1)
            step = start
            break
        }
        for i in self.children{
            i.axisLocation = start
            start = start + i.axisSize + step
        }
    }
    
    private func layoutCross(){
        let height = self.crossAsParentSize
        for i in self.children{
            switch(self.align){
                
            case .start:
                i.crossLocation = 0
                break
            case .center:
                i.crossLocation = (height - i.crossSize) / 2
                break
            case .end:
                i.crossLocation = (height - i.crossSize)
                break
            case .fill:
                i.crossLocation = 0
                break
            }
        }
    }
    private func childLayout(){
        self.resize()
        self.layoutAxis()
        self.layoutCross()
        for i in self.children{
            i.childLayout()
        }
    }
    public func layout(){
        self.selfSize()
        self.childLayout()
    }
    
    public init(){ }
}
