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
public protocol DatabaseModel{
    static var tableName:String { get }
    static var declare:[DatabaseColumeDeclare] { get }
    var model:Dictionary<String,Any> { get set}
    init()
}
extension DatabaseModel{

    public func create(db:Database){
        let sql = DatabaseGenerator.Table(ifNotExists: true, tableName: .name(name:Self.tableName), columeDefine: Self.declare)
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
    public func bind<T:DatabaseModel>(model:T) throws{
        let  model = model.model
        for i in model{
            try self.bind(name: "@" + i.key, value: i.value)
        }
    }
    public func colume<T:DatabaseModel>(model:inout T){
        for i in 0 ..< self.columeCount{
            model.model[self.columeName(index: i)] = self.colume(index: i)
        }
    }
}

extension DatabaseModel{
    public subscript<T>(dynamicMember dynamicMember:String)->T?{
        get{
            self.model[dynamicMember] as? T
        }
        set{
            self.model[dynamicMember] = newValue
        }
    }
}

public struct DatabaseQueryModel<T:DatabaseModel>{
    public var select:DatabaseGenerator.Select
    public init(select:DatabaseGenerator.Select){
        self.select = select
    }
    public func query(db:Database,param:DatabaseModel? = nil) throws ->[T] {
        let rs = try db.prepare(sql: self.select.sqlCode)
        var results:[T] = []
        if let dn = param{
            try rs.bind(model: dn)
        }
        while try rs.step() == .hasColumn {
            var result = T()
            rs.colume(model: &result)
            results.append(result)
        }
        rs.close()
        return results
    }
    public func insert<P:DatabaseModel>(db:Database,model:P) throws {
        let sql = DatabaseGenerator.Insert(insert: .insert, table: .name(name: P.tableName), colume: P.declare.map{$0.name}, value:select).sqlCode
        let rs = try db.prepare(sql: sql)
        try rs.step()
        rs.close()
    }
}
