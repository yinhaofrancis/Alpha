//
//  butterfly.swift
//  butterfly
//
//  Created by hao yin on 2022/10/28.
//

import Foundation

public struct Router<T:AnyObject>{
    
    public var build:()->T
    
    public var memory:MemeoryType  = .new
    
    public var name:String
    
    public init<I>(proto:I.Type,
                   memory: MemeoryType = .new,
                   build: @escaping () -> T) {
        self.init(name: "\(proto)",memory: memory, build: build)
    }
    
    public init(name:String,
                   memory: MemeoryType = .new,
                   build: @escaping () -> T) {
        self.build = build
        self.memory = memory
        self.name = name
    }
}
protocol kk{
    
}
public indirect enum Route<T>{
    case interface(name:Any,memory:MemeoryType,build: () -> T)
}

func s(){
    Route.interface(name: kk.self, memory: .new) {
        UIViewController()
    }
}
public class butterfly<T:AnyObject>{
    
    @resultBuilder
    public struct RouterBuilder<T:AnyObject>{
        public static func buildBlock(_ components: Router<T>...) -> [String:Router<T>] {
            return components.reduce(into: [:]) { partialResult, router in
                partialResult[router.name] = router
            }
        }
        public static func buildLimitedAvailability(_ component: [String : Router<T>]) -> [String : Router<T>] {
            return component
        }
        public static func buildEither(first component: [String : Router<T>]) -> [String : Router<T>] {
            return component
        }
        public static func buildEither(second component: [String : Router<T>]) -> [String : Router<T>] {
            return component
        }
        public static func buildArray(_ components: [[String : Router<T>]]) -> [String : Router<T>] {
            components.reduce(into: [:]) { partialResult, i in
                partialResult.merge(i) { a, b in
                    b
                }
            }
        }
        public static func buildOptional(_ component: [String : Router<T>]?) -> [String : Router<T>] {
            return component ?? [:]
        }
    }
    
    private var singlten:RWDictionary<String,T> = RWDictionary()
    
    private var weakSinglten:RWDictionary<String,WeakContent<T>> = RWDictionary()
    
    private var config:RWDictionary<String,Router<T>> = RWDictionary()
    
    public func register(router:Router<T>){
        self.config[router.name] = router
    }
    
    public func register(@RouterBuilder<T> builder:()->[String:Router<T>]){
        config.merge(dic: builder())
    }
    
    func dequeue(route:String)->T?{
        if let instant = self.singlten[route] {
            return instant
        }
        if let instant = self.weakSinglten[route]?.content {
            return instant
        }
        guard let config = self.config[route] else { return nil }
        let instant = config.build()
        switch(config.memory){
            
        case .singlton:
            self.singlten[route] = instant
            return instant
        case .weakSinglton:
            self.weakSinglten[route] = WeakContent(content: instant)
            return instant
        case .new:
            return instant
        }
        
    }
    
    public func dequeue<INF>()->INF?{
        self.dequeue(route: "\(INF.self)") as? INF
    }
}
public let sharedButterfly = butterfly<AnyObject>()

public let viewButterfly = butterfly<UIView>()
