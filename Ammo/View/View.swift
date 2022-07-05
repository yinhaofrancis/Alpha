//
//  View.swift
//  Ammo
//
//  Created by hao yin on 2022/7/1.
//

import Foundation
import UIKit

private var itemKey = "itemKey"

extension UIView:FillContentProtocol{
    public var item:Container{
        get{
            if let c = objc_getAssociatedObject(self, &itemKey) as? Container{
                return c
            }
            let cc = Container(items: [], width: nil, height: nil, grow: 1, shrink: 1)
            cc.fillContent = self
            objc_setAssociatedObject(self, &itemKey, cc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cc
        }
        set{
            newValue.fillContent = self
            objc_setAssociatedObject(self, &itemKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private func loadItem(){
        self.item.children = self.subviews.compactMap({$0.item})
        for i in self.subviews{
            i.loadItem()
        }
    }
    public func layout(){
        self.loadItem()
        self.item.width = .init(floatLiteral: self.frame.width)
        self.item.height = .init(floatLiteral: self.frame.height)
        self.item.relayout()
        self.syncLayoutResult()
    }
    public func syncLayoutResult(){
        self.frame = self.item.resultFrame ?? .zero
        for i in self.subviews{
            i.syncLayoutResult()
        }
    }
    public func constaintSize(size: CGSize) -> CGSize {
        return self.systemLayoutSizeFitting(size)
    }
}
public class StackView:UIView{
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.item = Stack(items: [], width: .init(floatLiteral: frame.width), height: .init(floatLiteral: frame.height), grow: 1, shrink: 1)
        self.stack.axis = .vertical
    }
    public var stack:Stack{
        return self.item as! Stack
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.item = Stack(items: [], width: nil, height: nil, grow: 1, shrink: 1)
        self.stack.axis = .vertical
    }
}
