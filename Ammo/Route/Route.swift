//
//  Route.swift
//  Ammo
//
//  Created by hao yin on 2022/5/26.
//

import Foundation


public protocol Router{
    
}

public struct Route{
    public var name:String
    public var router:Router
    public init(name:String,router:Router){
        self.router = router
        self.name = name
    }
}

public struct RouterSet{
    public init(routes:[String:Router]){
        self.routes = routes
    }
    public var routes:[String:Router]
}

@resultBuilder
public struct RouteBuilder{
    public static func buildBlock(_ components: Route...) -> RouterSet {
        let kv = components.reduce(into: [:]) { partialResult, route in
            partialResult[route.name] = route.router
        }
        return RouterSet(routes: kv)
    }
    
}
