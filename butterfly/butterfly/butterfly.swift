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
