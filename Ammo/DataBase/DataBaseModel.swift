//
//  DatabaseModel.swift
//  Alpha
//
//  Created by hao yin on 2022/4/19.
//

import Foundation
import UIKit

public protocol DataBaseProtocol{
    init()
    init(db:DataBase) throws
    static var name:String { get }
    
    var updates:DataBaseUpdate?{ get }
}

open class DataBaseObject:DataBaseProtocol{
    
    open var updates: DataBaseUpdate?{
        return nil
    }
    
    public required init(db: DataBase) throws {
        try Self.createTable(update: self.updates, db: db)
    }
    
    public required init() {}
    
    public static var name:String{
        return "\(Self.self)"
    }
}

extension DataBaseProtocol{
    
    public static func colume<T:DBType>(rs:DataBase.ResultSet,index:Int32)->T?{
        T.create(rs: rs, index: index)
    }
    public static func colume(rs:DataBase.ResultSet,index:Int32)->DBType?{
        if rs.columeDecType(index: index) == .jsonDecType{
            return JSONModel.create(rs: rs, index: index)
        }else if rs.columeDecType(index: index) == .dateDecType{
            return Date.create(rs: rs, index: index)
        }else{
            switch (rs.columeType(index: index)){
            case .nullCollumn:
                return nil
            case .intCollumn:
                return Int.create(rs: rs, index: index)
            case .doubleCollumn:
                return Double.create(rs: rs, index: index)
            case .textCollumn:
                return String.create(rs: rs, index: index)
            case .dataCollumn:
                return Data.create(rs: rs, index: index)
            }
        }
    }
    
    public var declare:TableDeclare{
        let cds = Mirror(reflecting: self).children.filter({$0.value is CollumnDeclare}).map { m in
            m.value as! CollumnDeclare
        }
        var dc = TableDeclare(name: Self.name, version: self.version, declare: cds)
        dc.updates = self.updates
        return dc;
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
                guard let v = a[tc.name] else {
                    return
                }
                tc.origin = v
            }
        }
    }
    
    public static func select<T:DataBaseProtocol>(db:DataBase,condition:QueryCondition? = nil) throws ->[T]{
        
        try TableModel.select(db: db,keys: T().declare.querykeys,table: self.name, condition: condition).map { tm in
            var m = T()
            m.tableModel = tm
            return m
        }
    }
    public static func delete(db:DataBase,condition:QueryCondition) throws{
        try TableModel.delete(db: db, table: self.name, condition: condition)
    }
    public var version:Int32{
        self.updates?.callbacks.max(by: { l, r in
            l.version < r.version
        })?.version ?? 0
    }
    public static func createTable(update:DataBaseUpdate?,db:DataBase) throws {
        if try db.tableExist(name: self.name){
            try update?.update(db: db)
        }else{
            try Self.init().declare.create(db: db)
        }
    }
}

public protocol DBType{
    static var originType:CollumnDecType { get }
    var isNull:Bool { get }
    var asDefault:String? { get }
    var stringValue: String { get }
    static func create(rs:DataBase.ResultSet,index:Int32)->Self?
    func bind(rs:DataBase.ResultSet,index:Int32) throws
}

extension Date:DBType{
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> Date? {
        rs.columeDate(index: index)
    }
    
    public static var originType: CollumnDecType{
        .dateDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String?{
        return "\(self.timeIntervalSince1970)"
    }
    public var stringValue: String{
        return "\(self.timeIntervalSince1970)"
    }
}

extension Int:DBType{
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> Int? {
        Int(rs.columeInt(index: index))
    }
    
    public var stringValue: String {
        return "\(self)"
    }
    
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
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> String? {
        rs.columeString(index: index)
    }
    
    public var stringValue: String {
        return "\"\(self)\""
    }
    
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
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> Double? {
        rs.columeDouble(index: index)
    }
    
    public static var originType: CollumnDecType {
        return .doubleDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String? {
        "\(self)"
    }
    public var stringValue: String {
        return "\(self)"
    }
}
extension Data:DBType{
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> Data? {
        rs.columeData(index: index)
    }
    
    public static var originType: CollumnDecType {
        return .dataDecType
    }
    public var isNull: Bool{
        return false
    }
    public var asDefault: String? {
        ""
    }
    public var stringValue: String {
        return ""
    }
    
}

extension Optional:DBType where Wrapped:DBType{
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> Optional<Wrapped>? {
        rs.colume(index: index)
    }    
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
    public var stringValue: String {
        return ""
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
        super.init(value:wrappedValue, type:T.originType, nullable: true, name: name, primaryKey: false, unique: false, autoInc: false)
    }
    public init(wrappedValue:T,name:String,primaryKey: Bool,autoInc: Bool = false){
        super.init(value:wrappedValue,type:T.originType, nullable: true, name: name, primaryKey: primaryKey, unique: false, autoInc: autoInc)
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
        super.init(value: self.wrappedValue.origin, type: self.wrappedValue.type, nullable: self.wrappedValue.nullable, name: self.wrappedValue.name, primaryKey: self.wrappedValue.primaryKey, unique: self.wrappedValue.unique, autoInc: self.wrappedValue.autoInc)
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
