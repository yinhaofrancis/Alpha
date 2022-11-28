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
@propertyWrapper
public class PathButterfly<T:Routable>{
    
    private var name:String
    private lazy var obj:T? = {
        try? ButterFlyRouter.shared.dequeueRouter(name: name)?.cls.init() as? T
    }()
    public var wrappedValue: T?{
        get{
            return obj
        }
        set{
            obj = newValue
        }
    }
    public init(name:String){
        self.name = name
    }
}


public class WrapParamButterfly{
    public var name:String
    public var value:Any?
    public init(name: String, value: Any? = nil) {
        self.name = name
        self.value = value
    }
}

@propertyWrapper
public class ParamButterfly<T>:WrapParamButterfly{
    
    public var wrappedValue: T?{
        guard let value else { return nil }
        return self.parseValue(value:value)
    
    }

    public func parseValue(value:Any)->T?{
        return value as? T
    }
    public init(name:String){
        super.init(name: name,value: nil)
    }
}
