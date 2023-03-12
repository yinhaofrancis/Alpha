//
//  File.swift
//  
//
//  Created by wenyang on 2023/3/8.
//

import Foundation
import SQLite3
import SQLite3.Ext

public enum CollumnType{
    case nullCollumn
    case intCollumn
    case doubleCollumn
    case textCollumn
    case dataCollumn
}

/// 列定义类型
public enum CollumnDecType:String{
    case intDecType = "INTEGER"
    case doubleDecType = "REAL"
    case textDecType = "TEXT"
    case dataDecType = "BLOB"
    case jsonDecType = "JSON"
    case dateDecType = "DATE"
    public var collumnType:CollumnType{
        switch(self){
        case .intDecType:
            return .intCollumn
        case .doubleDecType:
            return .doubleCollumn
        case .textDecType:
            return .textCollumn
        case .dataDecType:
            return .dataCollumn
        case .jsonDecType:
            return .textCollumn
        case .dateDecType:
            return .doubleCollumn
        }
    }
}

@resultBuilder
public struct ColumeDefine{
    public static func buildBlock(_ components: DatabaseColumeDeclare...) -> [DatabaseColumeDeclare] {
        return components
    }
}

public class DatabaseColumeDeclare{
    public init(name:String,
                type: CollumnDecType,
                primary: Bool = false,
                unique: Bool = false,
                notNull: Bool = false,keyPath:AnyKeyPath) {
        self.type = type
        self.name = name
        self.unique = unique
        self.notNull = notNull
        self.primary = primary
        self.keyPath = keyPath
    }
    
    public var name:String
    public var type:CollumnDecType
    public var unique:Bool = false
    public var notNull:Bool = false
    public var primary:Bool = false
    public var keyPath:AnyKeyPath

}
public class DatabaseColumeTypeDeclare<K,V>:DatabaseColumeDeclare{
    public init(name: String,
                type: CollumnDecType,
                primary: Bool = false,
                unique: Bool = false,
                notNull: Bool = false,
                keyPath: WritableKeyPath<K,V>) {
        super.init(name: name, type: type, primary: primary, unique: unique, notNull: notNull, keyPath: keyPath)
    }
}
public class DatabaseColumeJSONDeclare<K,V:Codable>:DatabaseColumeDeclare{
    public init(name: String,
                notNull: Bool = false,
                keyPath: WritableKeyPath<K,V>) {
        super.init(name: name, type: .jsonDecType, primary: false, unique: false, notNull: notNull, keyPath: keyPath)
    }
}

public protocol DatabaseModel{
    static var tableName:String { get }
    @ColumeDefine static var declare:[DatabaseColumeDeclare] { get }
}
extension DatabaseModel{
    public func keyPath<T>(key:String,type:T.Type)->AnyKeyPath?{
        Self.declare.first {$0.name == key}?.keyPath
    }
    public func keyValue<T>(key:String,type:T.Type)->T?{
        if let kvp = self.keyPath(key: key,type: type) as? WritableKeyPath<Self,T>{
            return self[keyPath: kvp]
        }
        if let kvp = self.keyPath(key: key,type: type) as? WritableKeyPath<Self,T?>{
            return self[keyPath: kvp]
        }
        return nil
    }
    public mutating func setKeyValue<T>(key:String,value:T){
        if let kvp = self.keyPath(key: key,type: T.self) as? WritableKeyPath<Self,T>{
            self[keyPath: kvp] = value
        }
        if let kvp = self.keyPath(key: key,type: T.self) as? WritableKeyPath<Self,T?>{
            self[keyPath: kvp] = value
        }
    }
    public subscript<T>(key:String)->T{
        get{
            self.keyValue(key: key, type: T.self)!
        }
        mutating set{
            self.setKeyValue(key: key, value: newValue)
        }
    }
    public func isJson(key:String)->Bool{
        return Self.declare.first { $0.name == key }?.type == .jsonDecType
    }
    public func setJson<T:Codable>(key:String,data:Data) throws ->T?{
        return try DapaJsonDecoder.decode(T.self, from: data)
    }
    
    public func setJson<T:Codable>(json:T) throws ->Data{
        return try DapaJsonEncoder.encode(json)
    }
    public var modelMap:[String:Any]{
        let c = Mirror(reflecting: self).children.filter{ $0.label != nil }.reduce(into: [:]) { partialResult, v in
            partialResult[v.label!] = v.value
        }
        return Self.declare.reduce(into: [:]) { partialResult, v in
            partialResult[v.name] = c[v.name]
        }
    }
}

public let DapaJsonDecoder:JSONDecoder = {
    let json = JSONDecoder();
    if #available(iOS 15.0, *) {
        json.allowsJSON5 = true
    } else {

    };
    return json
}()

public let DapaJsonEncoder:JSONEncoder = {
    let json = JSONEncoder()
    return json
}()

extension Database.ResultSet{
    public func bind<T:DatabaseModel>(model:T) throws{
        let  model = model.modelMap
        for i in model{
            try self.bind(name: i.key, value: i.value)
        }
    }
    public func colume<T:DatabaseModel>( model:inout T){
        for i in (0 ..< self.columeCount){
            let a = self.colume(index: i, type: self.columeDecType(index: i) ?? .textDecType)
            print(a)
        }
    }
}
