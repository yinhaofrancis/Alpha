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
    associatedtype Out:AnyObject
    var path:String { get }
    var build:()->Out { get }
    var mem:MemeoryType { get }
    var interceptor:Interceptor<Out>? { get }
}


public struct Router<T:AnyObject>:BaseRouter{
    
    public typealias Out = T
    
    public var interceptor: Interceptor<T>?
    
    public var mem: MemeoryType
    
    public var build: () -> T
 
    public var path: String

    public init(path: String,mem:MemeoryType = .new,interceptor:Interceptor<T>? = nil,build:@escaping ()->T) {
        self.path = path
        self.mem = mem
        self.interceptor = nil
        self.build = build
    }
}

@resultBuilder
public struct routerBuilder<T:AnyObject>{
    public static func buildBlock(_ components: Router<T>...) -> Dictionary<String,Router<T>> {
        components.reduce(into: [:]) { partialResult, br in
            partialResult[br.path] = br
        }
    }
}

public struct Config<T:AnyObject>{
    public private(set) var routerConfigMap:Dictionary<String,Router<T>> = [:]
    public init(@routerBuilder<T> callback:()->Dictionary<String,Router<T>>){
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


public struct Route<T:AnyObject>:Hashable{
    public static func == (lhs:Route<T>, rhs: Route<T>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public var routeName:String
    public var param:[String:Any]?
    public init(routeName: String, param: [String : Any]? = nil) {
        self.routeName = routeName
        self.param = param
    }
    public func hash(into hasher: inout Hasher) {
        self.routeName.hash(into: &hasher)
    }
}



//public class Interceptor<Target:AnyObject>{
//    func filter(route:Route<Target>)->Route<Target>{
//        return route
//    }
//}

public typealias Interceptor<T:AnyObject> = (Route<T>)->Route<T>

public func +<T:AnyObject> (l: @escaping Interceptor<T>,r:@escaping Interceptor<T>)->Interceptor<T>{
    return { i in
        let l = l(i)
        if i != l{
            return l
        }
        let r = r(l)
        if l != r{
            return r
        }
        return r
    }
}


private var map:RWDictionary<String,Any> = RWDictionary()
public class butterfly<T:AnyObject>{
    
    public static func shared(type:T.Type)->butterfly<T>{
        if let ob = map["\(type)"]{
            return ob as! butterfly<T>
        }
        let b = butterfly<T>()
        map["\(type)"] = b
        return b
    }
    public var config:RWDictionary<String,Router<T>> = RWDictionary()
    public var singlton:RWDictionary<String,T> = RWDictionary()
    public var weakSinglton:RWDictionary<String,WeakContent<T>> = RWDictionary()
    public var globalinterceptor:Interceptor<T>?
    public func loadConfig(config:Config<T>){
        self.config.merge(dic: config.routerConfigMap)
    }
    public init() { }
    
    func dequeue(route:String)->T?{
        
        guard let config = self.config[route] else { return nil}
        if let s = self.singlton[route] ?? self.weakSinglton[route]?.content{
            return s
        }
        let a = config.build()
        switch(config.mem){
            
        case .singlton:
            self.singlton[route] = a
            return a
        case .weakSinglton:
            self.weakSinglton[route] = WeakContent(content: a)
            return a
        case .new:
            return a
        }
        
    }
    func bind(param:[String:Any],content:T,route:String)->T{
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
    public func dequeue(route:Route<T>)->T?{
        guard let config = self.config[route.routeName] else { return nil }
        let bas = self.globalinterceptor?(route) ?? route
        let route = config.interceptor?(bas) ?? bas
        let t:T? = self.dequeue(route: route.routeName)
        guard let param = route.param else { return t }
        guard let t else { return t}
        return self.bind(param: param, content: t, route: route.routeName)
    }
}
public protocol Routable:AnyObject{
    
}
extension Routable{
    public static func route(route:Route<Self>)->Self?{
        butterfly.shared(type: Self.self).dequeue(route:route)
    }
    public var route:String?{
        return (Mirror(reflecting: self).children.filter { i in
            i.value is RouteName
        }.first?.value as? RouteName)?.wrappedValue
    }
}
extension UIViewController:Routable{
    
}
extension UIView:Routable{
    
}

@propertyWrapper
public class RouteFactory<T:Routable>{
    private var _wrappedValue:T?
    
    public var wrappedValue: T?{
        if let wv = self._wrappedValue{
            return wv
        }
        let wv = T.route(route:route)
        self._wrappedValue = wv
        return wv
    }
    private var route:Route<T>{
        didSet{
            self._wrappedValue = nil
        }
    }
    
    public init(route:Route<T>) {
        self.route = route
    }
    public var projectedValue:Route<T>{
        return route
    }
}
