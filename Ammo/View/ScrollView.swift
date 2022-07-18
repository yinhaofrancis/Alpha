//
//  ScrollView.swift
//  Ammo
//
//  Created by hao yin on 2022/7/11.
//

import Foundation
import UIKit

public class ScrollView:UIView{
    public var panGesture:UIPanGestureRecognizer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(ScrollView.pan(pan:)))
        self.addGestureRecognizer(self.panGesture!)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(ScrollView.pan(pan:)))
        self.addGestureRecognizer(self.panGesture!)
    }
    private var current:CGPoint = .zero
    private var lastLocation:CGPoint = .zero
    @objc private func pan(pan:UIPanGestureRecognizer){
        switch(pan.state){
            
        case .began:
            self.current = pan.location(in: self.window)
            self.lastLocation = self.contentOffset
            break
        case .changed:
            let temp = pan.location(in: self.window)
            print(temp)
            let deltax = temp.x - current.x
            let deltay = temp.y - current.y
            self.contentOffset = CGPoint(x: self.lastLocation.x - deltax, y: self.lastLocation.y - deltay)
            break
        case .ended:
            let temp = pan.location(in: self.window)
            let deltax = temp.x - current.x
            let deltay = temp.y - current.y
            self.contentOffset = CGPoint(x: self.lastLocation.x - deltax, y: self.lastLocation.y - deltay)
            break
        default:
            break
        }
    }
    public var contentOffset:CGPoint{
        get{
            return self.bounds.origin
        }
        set{
            self.bounds.origin = newValue
        }
    }
}
