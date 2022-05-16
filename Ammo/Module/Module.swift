//
//  Module.swift
//  Ammo
//
//  Created by hao yin on 2022/5/13.
//

import Foundation

public enum Memory{
    case Singleton
    case Normal
}
public struct EventKey:RawRepresentable{
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    public typealias RawValue = String
    
    public static var onCreate = EventKey(rawValue: "onCreate")
    
    public static var onFinish = EventKey(rawValue: "onFinish")
    
}

public protocol ModuleEntry{
    typealias ModuleReturn = ([String:Any]?)->Void
    var name:EventKey { get }
    func call(param:[String:Any]?,ret:ModuleReturn?)
}

public struct ClosureEntry:ModuleEntry{
    public var name: EventKey
    
    public var call:([String:Any]?,ModuleReturn?)->Void
    
    public func call(param: [String : Any]?,ret:ModuleReturn?) {
        #if DEBUG
        
        print("event: " + self.name.rawValue, "param \(String(describing: param))")
        
        #endif
        self.call(param,ret)
    }
    
    
    public init(name:EventKey,call:@escaping ([String:Any]?,ModuleReturn?)->Void){
        self.name = name
        self.call = call
    }
    
}

public protocol Module{
    static var memory: Memory { get }
    static var name:String { get }
    @ModuleBuilder var entries:[String:ModuleEntry] { get }
    init()
}

extension Module{
    
    public func call(event:EventKey)->ModuleEntry?{
        self.entries[event.rawValue]
    }
}


public class ModuleBucket{
    private var singletonModule:[String:Module] = [:]
    private var configuration:()->[String:Module.Type] = { return [:] }
    public init(@ModuleBucketBuilder module:@escaping ()->[String:Module.Type]){
        self.resetConfiguration(module: module)
    }
    public func module(name:String)->Module?{
        if let s = singletonModule[name]{
            return s
        }else{
            guard let ty =  self.configuration()[name] else {
                return nil
            }
            let module = ty.init()
            module.call(event: .onCreate)?.call(param: nil, ret: nil)
            return module
        }
    }
    fileprivate func resetConfiguration(@ModuleBucketBuilder module:@escaping ()->[String:Module.Type]){
        self.configuration = module
        let kv = module()
        for i in kv{
            if i.value.memory == .Singleton{
                singletonModule[i.key] = i.value.init()
                singletonModule[i.key]?.call(event: .onCreate)?.call(param: nil, ret: nil)
            }
        }
    }
}
public final class SharedModuleBucket:ModuleBucket{
    private static var configration:()->[String:Module.Type] = {[:]}
    public static func sharedConfiguration(@ModuleBucketBuilder module:@escaping ()->[String:Module.Type]){
        configration = module
    }
    public static func resetConfiguration(){
        self.shared.resetConfiguration(module: configration)
    }
    public static var shared:SharedModuleBucket = {
        SharedModuleBucket(module: SharedModuleBucket.configration)
    }()
}

@resultBuilder
public struct ModuleBuilder{
    public static func buildBlock(_ components: ModuleEntry ...) -> [String:ModuleEntry] {
        return components.reduce(into: [:]) { partialResult, me in
            partialResult[me.name.rawValue] = me
        }
    }
}
@resultBuilder
public struct ModuleBucketBuilder{
    public static func buildBlock(_ components: Module.Type ...) -> [String:Module.Type] {
        return components.reduce(into: [:]) { partialResult, me in
            partialResult[me.name] = me
        }
    }
}

@propertyWrapper
public class ModuleState<T>{
    public var wrappedValue: T{
        get{
            return self.origin
        }
        set{
            self.origin = newValue
        }
    }
    public var origin:T
    public init(wrappedValue:T){
        self.origin = wrappedValue
    }
}
@propertyWrapper
public class ModuleNullableState<T>{
    public var wrappedValue: T?{
        get{
            return self.origin
        }
        set{
            self.origin = newValue
        }
    }
    public var origin:T?
    public init(wrappedValue:T?){
        self.origin = wrappedValue
    }
}

@propertyWrapper
public struct ModuleProperty<T:Module>{
    public var wrappedValue:T?{
        bucket.module(name: self.name) as? T
    }
    public var bucket:ModuleBucket
    public var name:String
    public init(name:String,bucket:ModuleBucket = SharedModuleBucket.shared){
        self.bucket = bucket
        self.name = name
    }
}
