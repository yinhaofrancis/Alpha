//
//  butterfly.swift
//  butterfly
//
//  Created by hao yin on 2022/10/28.
//

import Foundation
import UIKit


public enum MemeoryType{
    case singlton
    case weakSinglton
    case new
}

public protocol BaseRouter{
    var path:String { get }
    var build:()->AnyObject { get }
    var mem:MemeoryType { get }
}


public struct Router<T:AnyObject>:BaseRouter{
    public var mem: MemeoryType
    
    public var build: () -> AnyObject
 
    public var path: String
    
    public init(path: String,mem:MemeoryType = .new,build:@escaping ()->T) {
        self.path = path
        self.mem = mem
        self.build = build
    }
}

@resultBuilder
public struct routeBuilder{
    public static func buildBlock(_ components: BaseRouter...) -> Dictionary<String,BaseRouter> {
        components.reduce(into: [:]) { partialResult, br in
            partialResult[br.path] = br
        }
    }
}

public struct Config{
    public private(set) var routerConfigMap:Dictionary<String,BaseRouter> = [:]
    public init(@routeBuilder callback:()->Dictionary<String,BaseRouter>){
        self.routerConfigMap = callback()
    }
}
public class WeakContent<T:AnyObject>{
    weak var content:T?
    public init(content: T? = nil) {
        self.content = content
    }
}


public class RWDictionary<Key, Value> where Key : Hashable{
    var _content:Dictionary<Key,Value> = [:]
    public var content: Dictionary<Key,Value> {
        get{
            pthread_rwlock_rdlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            return self._content
        }
        set{
            pthread_rwlock_wrlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            self._content = newValue
        }
    }
    public func merge(dic:Dictionary<Key,Value>){
        self._content.merge(dic) { a, b in
            return b
        }
    }
    
    public var lock:pthread_rwlock_t = pthread_rwlock_t()
    
    public subscript(key:Key)->Value?{
        get{
            pthread_rwlock_rdlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            return self._content[key]
        }
        set{
            pthread_rwlock_wrlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            self._content[key] = newValue
        }
    }
    public init(content:Dictionary<Key,Value>) {
        pthread_rwlock_init(&self.lock, nil)
        self._content = content
    }
    public init() {
        pthread_rwlock_init(&self.lock, nil)
    }
    deinit{
        pthread_rwlock_destroy(&self.lock)
    }
}

public class BaseRouteParam{
    var innerValue:Any?
    var key:String
    public init(key:String,innerValue: Any? = nil) {
        self.innerValue = innerValue
        self.key = key
    }
}

@propertyWrapper
public class RouteParam<T>:BaseRouteParam{
    
    public var wrappedValue: T? {
        #if DEBUG
        let t = innerValue as? T
        assert(t != nil)
        return t
        #else
        return innerValue as? T
        #endif
        
    }
    public init(key:String,innerValue: T? = nil) {
        super.init(key: key, innerValue: innerValue)
    }
}

@propertyWrapper
public class RouteName:BaseRouteParam{
    
    public var wrappedValue: String? {
        return innerValue as? String
    }
    public init() {
        super.init(key: "__route__", innerValue: nil)
    }
}


public class butterfly{
    public static var shared:butterfly = butterfly()
    public var config:RWDictionary<String,BaseRouter> = RWDictionary()
    public var singlton:RWDictionary<String,AnyObject> = RWDictionary()
    public var weakSinglton:RWDictionary<String,WeakContent<AnyObject>> = RWDictionary()
    public func loadConfig(config:Config){
        self.config.merge(dic: config.routerConfigMap)
    }
    public init() { }
    
    func dequeue<T:AnyObject>(route:String)->T?{
        
        guard let config = self.config[route] else { return nil}
        
        if let s = self.singlton[route] ?? self.weakSinglton[route]?.content{
            return s as? T
        }
        switch(config.mem){
            
        case .singlton:
            let a = config.build()
            self.singlton[route] = a
            return a as? T
        case .weakSinglton:
            let a = config.build()
            self.weakSinglton[route] = WeakContent(content: a)
            return a as? T
        case .new:
            return config.build() as? T
        }
        
    }
    func bind<T:AnyObject>(param:[String:Any],content:T,route:String)->T{
        let map = Mirror(reflecting: content).children.filter { i in
            i.value is BaseRouteParam
        }.map { i in
            i.value as! BaseRouteParam
        }
        for i in map{
            if(i.key == "__route__"){
                i.innerValue = route
            }else{
                i.innerValue = param[i.key]
            }
            
        }
        return content
    }
    
    public func dequeue<T:AnyObject>(route:String,param:[String:Any]?)->T?{
        let t:T? = self.dequeue(route: route)
        guard let param else { return t }
        guard let t else { return t}
        return self.bind(param: param, content: t, route: route)
    }
}
extension UIViewController{
    public static func route(route:String,param:[String:Any]?)->UIViewController?{
        butterfly.shared.dequeue(route: route, param: param)
    }
    public var route:String?{
        return (Mirror(reflecting: self).children.filter { i in
            i.value is RouteName
        }.first?.value as? RouteName)?.wrappedValue
    }
}

extension UIView{
    public static func route(route:String,param:[String:Any]?)->UIView?{
        butterfly.shared.dequeue(route: route, param: param)
    }
}

