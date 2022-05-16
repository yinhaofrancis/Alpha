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
    
    
}

public protocol ModuleEntry{
    var name:EventKey { get }
    func call(param:[String:Any]?)
}

public struct ClosureEntry:ModuleEntry{
    public var name: EventKey
    
    public var call:([String:Any]?)->Void
    
    public func call(param: [String : Any]?) {
        #if DEBUG
        
        print("event: " + self.name.rawValue, "param \(String(describing: param))")
        
        #endif
        self.call(param)
    }
    
    
    public init(name:EventKey,call:@escaping ([String:Any]?)->Void){
        self.name = name
        self.call = call
    }
    
}

public protocol Module{
    var memory: Memory { get }
    var name:String { get }
    @ModuleBuilder var entries:[String:ModuleEntry] { get }
}

extension Module{
    
    public func call(event:EventKey)->ModuleEntry?{
        self.entries[event.rawValue]
    }
}


public class ModuleBucket{
    private var singletonModule:[String:Module] = [:]
    private var configuration:()->[String:Module]
    public init(@ModuleBucketBuilder module:@escaping ()->[String:Module]){
        self.configuration = module
        self.resetConfiguration(module: module)
    }
    public func module(name:String)->Module?{
        if let s = singletonModule[name]{
            return s
        }else{
            return self.configuration()[name]
        }
    }
    fileprivate func resetConfiguration(@ModuleBucketBuilder module:@escaping ()->[String:Module]){
        self.configuration = module
        let kv = module()
        for i in kv{
            if i.value.memory == .Singleton{
                singletonModule[i.key] = i.value
            }
        }
    }
}
public final class SharedModuleBucket:ModuleBucket{
    private static var configration:()->[String:Module] = {[:]}
    public static func sharedConfiguration(@ModuleBucketBuilder module:@escaping ()->[String:Module]){
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
    public static func buildBlock(_ components: Module ...) -> [String:Module] {
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
