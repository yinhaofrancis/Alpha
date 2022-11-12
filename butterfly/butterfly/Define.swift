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

public struct Router<T:Routable>:RouterProtocol{
    
    public var name: String
    
    public var cls: T.Type
    
    public var memory: MemoryType
    
    public typealias R = T
    
    public init(proto:Any ,memory:MemoryType = .new,cls:T.Type){
        self.init(name: "\(proto)", memory: memory, cls: cls)
    }
    public init(name:String ,memory:MemoryType = .new,cls:T.Type){
        self.name = name
        self.memory = memory
        self.cls = cls
    }
}
