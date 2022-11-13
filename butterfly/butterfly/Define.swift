//
//  Define.swift
//  butterfly
//
//  Created by wenyang on 2022/11/13.
//

import Foundation

public enum MemoryType{
    case singlton
    case weakSingle
    case new
}
public protocol Routable:AnyObject{
    
    init() throws
}

public protocol RouterProtocol{
    
    associatedtype R:Routable
    
    var name:String { get }
    
    var cls:R.Type { get }
    
    var memory:MemoryType { get }
}

public struct Router<P,T:Routable>:RouterProtocol{
    
    public var name: String
    
    public var cls: T.Type
    
    public var memory: MemoryType
    
    public typealias R = T
    
    public init(proto:P.Type ,memory:MemoryType = .new,cls:T.Type){
        self.name = "\(proto)"
        self.memory = memory
        self.cls = cls
    }
}
public struct PathRouter<T:Routable>:RouterProtocol{
    
    public var name: String
    
    public var cls: T.Type
    
    public var memory: MemoryType
    
    public typealias R = T
    
    public init(name:String ,memory:MemoryType = .new,cls:T.Type){
        self.name = name
        self.memory = memory
        self.cls = cls
    }
}


