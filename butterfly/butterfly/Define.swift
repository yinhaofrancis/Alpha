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

public protocol PathRoutable:Routable{
    
    var path:String? { get }
}
public protocol ParamRoutable:PathRoutable{
    
}
extension ParamRoutable{
    public func bindParam(param:Dictionary<String,Any>){
        Mirror(reflecting: self).children.filter { i in
            i.label != nil && i.value is WrapParamButterfly
        }.map { i in
            i.value as! WrapParamButterfly
        }.forEach { i in
            i.value = param[i.name]
        }
    }
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


@dynamicMemberLookup
public struct RouteParam<T>{
    
    var content:T
    
    public subscript<P>(dynamicMember dynamicMember:KeyPath<T,P>)->P{
        self.content[keyPath: dynamicMember]
    }

    public init(content:T){
        self.content = content
    }
    public init?(content:Optional<T>) {
        switch(content){
        case let .some(c):
            self.content = c
            break
        default:
            return nil
        }
        
    }
}
extension RouteParam where T == Dictionary<String,Any>{
    public subscript(dynamicMember dynamicMember:String)->Any?{
        self.content[dynamicMember]
    }
}
