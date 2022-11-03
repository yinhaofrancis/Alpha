//
//  File.swift
//  butterfly
//
//  Created by hao yin on 2022/11/1.
//

import Foundation
public class Module{
    public static var shared:Module = Module()
    public func addRoute(router:Router<AnyObject>){
        butterfly.shared(name: "__module__").addRouter(router: router)
    }
    public func dequeue<T>(route:Route<T>)->T?{
        
        butterfly.shared(name: "__module__").dequeue(route: Route(routeName: route.routeName,param: route.param)) as? T
    }
}

public func interface<T>(proto:T)->T?{
    Module.shared.dequeue(route: Route(proto: T.self))
}

public func register<T,O:AnyObject>(proto:T.Type,mem:MemeoryType = .weakSinglton,callback:@escaping ()->O){
    Module.shared.addRoute(router: Router(proto: proto, mem: mem,build: callback))
}
