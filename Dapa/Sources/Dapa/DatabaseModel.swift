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

public class DatabaseColumeDeclare{
    public init(name:String,
                type: CollumnDecType,
                primary: Bool = false,
                unique: Bool = false,
                notNull: Bool = false) {
        self.type = type
        self.name = name
        self.unique = unique
        self.notNull = notNull
        self.primary = primary
    }
    
    public var name:String
    public var type:CollumnDecType
    public var unique:Bool = false
    public var notNull:Bool = false
    public var primary:Bool = false
}

@dynamicMemberLookup
public protocol DatabaseResult{
    var model:Dictionary<String,Any> { get set}
    init()
}

public struct DatabaseResultModel:DatabaseResult{
    public init() {
        self.model = Dictionary()
    }
    public var model: Dictionary<String, Any>
}

public protocol DatabaseModel:DatabaseResult{
    static var tableName:String { get }
    static var declare:[DatabaseColumeDeclare] { get }
    
}
extension DatabaseModel{

    public func create(db:Database){
        let sql = DatabaseGenerator.Table(ifNotExists: true, tableName: .name(name:Self.tableName), columeDefine: Self.declare)
        db.exec(sql: sql.sqlCode)
    }
    public func createIndex(index:String,withColumn:String,db:Database){
        let sql = DatabaseGenerator.Index(indexName: .name(name: index), tableName: Self.tableName, columes: [withColumn])
        db.exec(sql: sql.sqlCode)
    }
    public func insert(db:Database) throws {
        let col = Self.declare.map{$0.name}
        let sql = DatabaseGenerator.Insert(insert: .insert, table: .name(name: Self.tableName), colume:col , value: col.map { "@" + $0 })
        let rs = try db.prepare(sql: sql.sqlCode)
        try rs.bind(model: self)
        _ = try rs.step()
        rs.close()
    }
    public func replace(db:Database) throws {
        let col = Self.declare.map{$0.name}
        let sql = DatabaseGenerator.Insert(insert: .insertReplace, table: .name(name: Self.tableName), colume:col , value: col.map { "@" + $0 })
        let rs = try db.prepare(sql: sql.sqlCode)
        try rs.bind(model: self)
        try rs.step()
        rs.close()
    }
    
    public func update(db:Database) throws {
        
        let kv:[String:String] = self.model.keys.reduce(into: [:]) { partialResult, s in
            partialResult[s] = "@" + s
        }
        let sql = DatabaseGenerator.Update(keyValue: kv, table: .name(name: Self.tableName), condition: self.primaryCondition)
        let rs = try db.prepare(sql: sql.sqlCode)
        try rs.bind(model: self)
        try rs.step()
        rs.close()
    }
    public func delete(db:Database) throws {
 
        let sql = DatabaseGenerator.Delete(table: .name(name: Self.tableName), condition: self.primaryCondition)
        let rs = try db.prepare(sql: sql.sqlCode)
        try rs.bind(model: self)
        _ = try rs.step()
        rs.close()
    }
    public mutating func sync(db:Database) throws {
        let sql = DatabaseGenerator.Select(tableName: .init(table: .name(name: Self.tableName)),condition: self.primaryCondition)
        let rs = try db.prepare(sql: sql.sqlCode)
        try rs.bind(model: self)
        try rs.step()
        rs.colume(model: &self)
        rs.close()
    }
    public var primaryCondition:String{
        Self.declare.filter { $0.primary }.map{ $0.name + "=@" + $0.name }.joined(separator: " and ")
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
    public func bind<T:DatabaseResult>(model:T) throws{
        let  model = model.model
        for i in model{
            try self.bind(name: "@" + i.key, value: i.value)
        }
    }
    public func colume<T:DatabaseResult>(model:inout T){
        for i in 0 ..< self.columeCount{
            model.model[self.columeName(index: i)] = self.colume(index: i)
        }
    }
}

extension DatabaseResult{
    public subscript(dynamicMember dynamicMember:String)->Any{
        get{
            self.model[dynamicMember] as Any
        }
        set{
            self.model[dynamicMember] = newValue
        }
    }
    public subscript<T>(dynamicMember dynamicMember:String)->T?{
        get{
            self.model[dynamicMember] as? T
        }
    }
}
extension DatabaseModel{
    public static func select(condition:String? = nil,
                              orderBy: [DatabaseGenerator.OrderBy] = [],
                              limit:UInt64? = nil,
                              offset:UInt64? = nil)->DatabaseQueryModel{
        let sql = DatabaseGenerator.Select(tableName: .init(table: .name(name: self.tableName)),
                                           condition: condition,
                                           orderBy: orderBy,
                                           limit: limit,
                                           offset: offset)
        return DatabaseQueryModel(sql: sql)
    }
    public static func update(keyValues:[String:String],condition:String? = nil)->DatabaseQueryModel{
        let sql = DatabaseGenerator.Update(keyValue: keyValues, table: .name(name: self.tableName), condition: condition)
        return DatabaseQueryModel(sql: sql)
    }
    public static func delete(condition:String)->DatabaseQueryModel{
        let sql = DatabaseGenerator.Delete(table: .name(name: self.tableName), condition: condition)
        return DatabaseQueryModel(sql: sql)
    }
    public func insert(type:DatabaseGenerator.Insert.InsertType)->DatabaseQueryModel{
        let keys = self.model.keys
        let sql = DatabaseGenerator.Insert(insert: type, table: .name(name: Self.tableName), colume: keys.map{$0}, value:keys.map{"@"+$0})
        return DatabaseQueryModel(sql: sql)
    }
    public static func count(condition:String? = nil)->DatabaseQueryModel{
        let sql = DatabaseGenerator.Select(colume: [.colume(name: "COUNT(*) as count")],tableName: .init(table: .name(name: Self.tableName)),condition: condition)
        return DatabaseQueryModel(sql: sql)
    }
}
public struct DatabaseQueryModel{
    public var sql:DatabaseExpress
    public init(sql:DatabaseExpress){
        self.sql = sql
    }
    public func query<T:DatabaseResult>(db:Database,param:[String:Any] = [:]) throws ->[T] {
        let rs = try db.prepare(sql: self.sql.sqlCode)
        var results:[T] = []
        for i in param{
            try rs.bind(name: i.key, value: i.value)
        }
        while try rs.step() == .hasColumn {
            var result = T()
            rs.colume(model: &result)
            results.append(result)
        }
        rs.close()
        return results
    }
    public func exec(db:Database,param:[String:Any] = [:]) throws {
        let rs = try db.prepare(sql: self.sql.sqlCode)
        for i in param{
            try rs.bind(name: i.key, value: i.value)
        }
        try rs.step()
        rs.close()
    }
}
