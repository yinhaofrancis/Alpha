//
//  butterfly.swift
//  butterfly
//
//  Created by hao yin on 2022/10/28.
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

public class ButterFlyRouter{
    
    private var register = RWDictionary<String,any RouterProtocol>()
    
    private var singleton = RWDictionary<String,Routable>()
    
    private var weakSingleton = RWDictionary<String,WeakContent<AnyObject>>()
    
    public func register(route: any RouterProtocol){
        self.register[route.name] = route
    }
    
    private func dequeueRouter(name:String)->(any RouterProtocol)?{
        self.register[name]
    }
    
    public func dequeue<P>(proto:P.Type) throws -> P?{
        let name = "\(proto)"
        
        guard let router = self.dequeueRouter(name: name) else { return nil }
        
        let key = "\(router.cls)"
        
        if let inst = self.singleton[key]{
            return inst as? P
        }
        
        if let inst = self.weakSingleton[key]?.content{
            return inst as? P
        }
        
        let inst = try router.cls.init()
        
        switch(router.memory){
            
        case .singlton:
            self.singleton[key] = inst
            break
        case .weakSingle:
            self.weakSingleton[key] = WeakContent(content: inst)
            break
        case .new:
            break
        }
        return inst as? P
    }
    
    private func bind(module:Routable){
        
    }
    
    public static let shared:ButterFlyRouter = ButterFlyRouter()
}

extension UIView:Routable{
    
}

extension UIViewController:Routable{
    
}

