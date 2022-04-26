//
//  DatabaseModel.swift
//  Alpha
//
//  Created by hao yin on 2022/4/19.
//

import Foundation

open class DataBaseObject{
    public static var name:String{
        return NSStringFromClass(self).replacingOccurrences(of: ".", with: "_")
    }
    public var declare:TableDeclare{
        let cds = Mirror(reflecting: self).children.filter({$0.value is CollumnDeclare}).map { m in
            m.value as! CollumnDeclare
        }
        return TableDeclare(name: Self.name, declare: cds)
    }
    public var tableModel:TableModel{
        get{
            TableModel(name: Self.name, declare: Mirror(reflecting: self).children.filter({$0.value is TableColumn}).map ({$0.value as! TableColumn}))
        }
        set{
            let a = newValue.declare.reduce(into: [:]) { partialResult, r in
                partialResult[r.name] = r.origin
            }
            Mirror(reflecting: self).children.filter({$0.value is TableColumn}).forEach { kv in
                let tc = kv.value as! TableColumn
                tc.origin = a[tc.name]!
            }
        }
    }
    
    public static func select<T:DataBaseObject>(db:DataBase,condition:QueryCondition? = nil) throws ->[T]{
        
        try TableModel.select(db: db,keys: T().declare.querykeys,table: self.name, condition: condition).map { tm in
            let m = T()
            m.tableModel = tm
            return m
        }
    }
    public static func delete(db:DataBase,condition:QueryCondition) throws{
        try TableModel.delete(db: db, table: self.name, condition: condition)
    }
    public required init() {}
}

public protocol DBType{
    static var originType:CollumnDecType { get }
    var isNull:Bool { get }
    var asDefault:String? { get }
}

extension Date:DBType{
    public static var originType: CollumnDecType{
        .dateDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String?{
        return "\(self.timeIntervalSince1970)"
    }
}

extension Int:DBType{
    public var asDefault: String? {
        "\(self)"
    }
    
    public static var originType: CollumnDecType {
        return .intDecType
    }
    public var isNull: Bool{
        return false
    }
}
extension String:DBType{
    public static var originType: CollumnDecType {
        return .textDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String? {
        self
    }
    
}
extension Double:DBType{
    public static var originType: CollumnDecType {
        return .doubleDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String? {
        "\(self)"
    }
    
}
extension Data:DBType{
    public static var originType: CollumnDecType {
        return .dataDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String? {
        ""
    }
    
}

extension Optional:DBType where Wrapped:DBType{
    public var asDefault: String? {
        switch(self){
            
        case .none:
            return nil
        case let .some(v):
            return v.asDefault
        }
    }
    
    public static var originType: CollumnDecType {
        Wrapped.originType
    }
    public var isNull: Bool{
        return self == nil
    }
}

@propertyWrapper
public class Col<T:DBType>:TableColumn{
    
    public var wrappedValue:T{
        get{
            self.origin as! T
        }
        set{
            self.origin = newValue
        }
    }
    public init(wrappedValue:T,name:String){
        super.init(value:wrappedValue, type:T.originType, nullable: true, name: name, primaryKey: false, unique: false)
    }
    public init(wrappedValue:T,name:String,primaryKey: Bool){
        super.init(value:wrappedValue,type:T.originType, nullable: true, name: name, primaryKey: primaryKey, unique: false)
    }
}

@propertyWrapper
public class FK<T:TableColumn>:TableColumn{
    public var wrappedValue:T
    public init(wrappedValue:T,
                refKey:String,
                refTable:DataBaseObject.Type? = nil,
                onUpdate:ForeignDeclareAction? = nil,
                onDelete:ForeignDeclareAction? = nil){
        self.wrappedValue = wrappedValue
        super.init(value: self.wrappedValue.origin, type: self.wrappedValue.type, nullable: self.wrappedValue.nullable, name: self.wrappedValue.name, primaryKey: self.wrappedValue.primaryKey, unique: self.wrappedValue.unique)
        self.foreignDeclare = ForeignDeclare(key: self.wrappedValue.name,
                                                          refKey: refKey,
                                                        table:refTable?.name ,
                                                          onDelete: onDelete,
                                                          onUpdate: onUpdate)
    }
    public override var origin: DBType{
        get{
            self.wrappedValue.origin
        }
        set{
            self.wrappedValue.origin = newValue
        }
    }
}
