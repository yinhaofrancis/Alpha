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

extension UIView:Routable{}
var __param_key = "___param"
var __path_key = "___path"
extension UIViewController:PathRoutable{

    public var path: URL?  {
        get{
            objc_getAssociatedObject(self, &__path_key) as? URL
        }
        set{
            objc_setAssociatedObject(self, &__path_key, newValue,.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}

public class BTFViewController<T>:UIViewController,ParamRoutable{
    public var param: RouteParam<T>?
}
