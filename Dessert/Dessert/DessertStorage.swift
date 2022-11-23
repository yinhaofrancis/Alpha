//
//  DessertStorage.swift
//  Dessert
//
//  Created by wenyang on 2022/11/22.
//

import Foundation
import UIKit

public class DessertStorage{
    public var map:[String:Set<UIView>]
    
    public init(){
        self.map = Dictionary()
    }
    public func cache<T:UIView>(view:T){
        let typestring = "\(type(of: view))"
        var sets = map[typestring]
        if(sets == nil){
            sets = Set()
        }
        sets?.insert(view)
        map[typestring] = sets
        for i in view.subviews{
            self.cache(view: i)
            i .removeFromSuperview()
        }
    }
    public func kickOut<T:UIView>(type:T.Type)->T?{
        self.map["\(type)"]?.removeFirst() as? T
    }
    public func clean(){
        self.map.removeAll()
    }
}
