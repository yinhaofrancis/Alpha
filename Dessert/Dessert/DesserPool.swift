//
//  DesserPool.swift
//  Dessert
//
//  Created by wenyang on 2022/11/22.
//

import Foundation
import UIKit

public class DesserPool{
    public var map:[String:Set<UIView>]
    
    public init(){
        self.map = Dictionary()
    }
    public func cache<T:UIView>(view:T){
        let typestring = "\(type(of: view))"
        var sets = map[typestring]
        if(sets == nil){
            sets = Set()
            map[typestring] = sets
        }
        sets?.insert(view)
        view.removeFromSuperview()
    }
    public func kickOut<T:UIView>(type:T.Type)->T{
        guard let v = self.map["\(type)"]?.removeFirst() as? T else { return T()}
        return v
    }
    public func clean(){
        self.map.removeAll()
    }
}
