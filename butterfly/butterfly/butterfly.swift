//
//  butterfly.swift
//  butterfly
//
//  Created by hao yin on 2022/10/28.
//

import UIKit
import ObjectiveC

public class ButterFlyRouter{
    
    private var register = RWDictionary<String,any RouterProtocol>()
    
    private var singleton = RWDictionary<String,Routable>()
    
    private var weakSingleton = RWDictionary<String,WeakContent<AnyObject>>()
    
    public func register(route: any RouterProtocol){
        self.register[route.name] = route
    }
    public func register(routeSet:RouteSet){
        routeSet.routes.forEach { rp in
            self.register(route: rp)
        }
    }
    
    public func register(@RouteBuilder routeSet:() -> RouteSet){
        self.register(routeSet: routeSet())
    }
    
    public func dequeueRouter(name:String)->(any RouterProtocol)?{
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
    
    public static let shared:ButterFlyRouter = ButterFlyRouter()
}

public struct RouteSet{
    
    public var routes:[any RouterProtocol]
    
    public init(routes: [any RouterProtocol]) {
        self.routes = routes
    }
}

@resultBuilder
public struct RouteBuilder{
    public static func buildBlock(_ components: any RouterProtocol...) -> RouteSet {
        RouteSet(routes: components)
    }
    public static func buildArray(_ components: [RouteSet]) -> RouteSet {
        RouteSet(routes: components.map { rs in
            return rs.routes
        }.flatMap { i in
            return i
        })
    }
    public static func buildEither(first component: RouteSet) -> RouteSet {
        return component
    }
    public static func buildEither(second component: RouteSet) -> RouteSet {
        return component
    }
    public static func buildOptional(_ component: RouteSet?) -> RouteSet {
        return RouteSet(routes: [])
    }
    public static func buildLimitedAvailability(_ component: RouteSet) -> RouteSet {
        return component
    }
}

extension UIView:ParamRoutable{
    
    public var path: String?  {
        get{
            objc_getAssociatedObject(self, &__path_key) as? String
        }
        set{
            objc_setAssociatedObject(self, &__path_key, newValue,.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

var __param_key = "___param"
var __path_key = "___path"
extension UIViewController:ParamRoutable{

    public var path: String?  {
        get{
            objc_getAssociatedObject(self, &__path_key) as? String
        }
        set{
            objc_setAssociatedObject(self, &__path_key, newValue,.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}

public let BR = ButterFlyRouter.shared
