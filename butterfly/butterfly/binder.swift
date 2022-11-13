//
//  File.swift
//  butterfly
//
//  Created by wenyang on 2022/11/12.
//

import Foundation

@propertyWrapper
public class butterfly<T>{
    
    private var name:String = "\(T.self)"
    private lazy var obj:T? = {
        try? ButterFlyRouter.shared.dequeue(proto: T.self)
    }()
    public var wrappedValue: T?{
        get{
            return obj
        }
        set{
            obj = newValue
        }
    }
    public init(){}
}
