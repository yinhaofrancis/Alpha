//
//  DatabaseModel.swift
//  Alpha
//
//  Created by hao yin on 2022/4/19.
//

import Foundation
import UIKit
/// 原始列类型
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
/// 外键Action
public struct ForeignDeclareAction:Hashable{
    let action:String
    static public var CASCADE:ForeignDeclareAction = ForeignDeclareAction(action: "CASCADE")
    static public var NO_ACTION:ForeignDeclareAction = ForeignDeclareAction(action: "NO ACTION")
    static public var RESTRICT:ForeignDeclareAction = ForeignDeclareAction(action: "RESTRICT")
    static public var SET_NULL:ForeignDeclareAction = ForeignDeclareAction(action: "SET NULL")
    static public var SET_DEFAULT:ForeignDeclareAction = ForeignDeclareAction(action: "SET DEFAULT")
}

/// 外键定义
public struct ForeignDeclare{
    public var key:String
    public var refKey:String
    public var table:String?
    public var onDelete:ForeignDeclareAction?
    public var onUpdate:ForeignDeclareAction?
    public var code:String{
        return "FOREIGN KEY(\(key)) " + self.alterCode
    }
    public var alterCode:String{
        let rf = table == nil ? refKey : "\(table!)(\(refKey))"
        return "REFERENCES \(rf) \(onDelete != nil ? "ON Delete \(onDelete!.action)":"") \(onUpdate != nil ? "ON Update \(onUpdate!.action)":"")"
    }
    public init(key:String, refKey:String,table:String?, onDelete:ForeignDeclareAction?,onUpdate:ForeignDeclareAction?){
        self.key = key
        self.refKey = refKey
        self.table = table
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
}
/// 列定义
public class CollumnDeclare{
    public var type:CollumnDecType
    public var nullable:Bool
    public var name:String
    public var primaryKey:Bool
    public var unique:Bool
    public var defaultValue:String?
    public var autoInc:Bool
    public var foreignDeclare:ForeignDeclare?
    public init(type:CollumnDecType,nullable:Bool, name:String, primaryKey:Bool,unique:Bool,defaultValue:String?,autoInc:Bool){
        self.type = type
        self.nullable = nullable
        self.name = name
        self.primaryKey = primaryKey
        self.unique = unique
        self.autoInc = autoInc
        self.defaultValue = defaultValue
    }
    public static func primaryCollumn(name:String,type:CollumnDecType)->CollumnDeclare{
        CollumnDeclare(type: type, nullable: false, name: name, primaryKey: true, unique: false, defaultValue: nil, autoInc: false)
    }
    public static func normalCollumn(name:String,type:CollumnDecType)->CollumnDeclare{
        CollumnDeclare(type: type, nullable: true, name: name, primaryKey: false, unique: false, defaultValue: nil, autoInc: false)
    }
    public var code:String{
        return "\(name) \(type.rawValue) \(unique ? "unique":"") \(nullable ? "" : "NOT NULL") \(self.defaultValue != nil ? "default \"\(self.defaultValue!)\"" : "" )"
    }
}

@resultBuilder
public struct TableBuild{
  
    public static func buildBlock(_ components: CollumnDeclare ...) -> [CollumnDeclare] {
        return components
    }
    
    public static func buildBlock(_ name:String,version:Int32,_ components: CollumnDeclare...) -> TableDeclare {
        return TableDeclare(name: name,version: version,declare: components)
    }
}

/// 表定义
public struct TableDeclare{
    public var name:String
    public var version:Int32
    public var updates:DataBaseUpdate?
    public var declare:[CollumnDeclare]
    public init(name:String,version:Int32,declare:[CollumnDeclare]){
        self.name = name
        self.declare = declare
        self.version = version
    }
    
    public static func declare(@TableBuild build:()->TableDeclare)->TableDeclare{
        return build()
    }
    public var querykeys:[String]{
        self.declare.map({$0.name})
    }
    public var primaryColume:[CollumnDeclare]{
        self.declare.filter({$0.primaryKey})
    }
    public var foreignColume:[CollumnDeclare]{
        self.declare.filter({$0.foreignDeclare != nil}).map { cd in
            if cd.foreignDeclare?.table == nil{
                cd.foreignDeclare?.table = self.name
            }
            return cd
        }
    }
    public func add(colume:CollumnDeclare,db:DataBase){
        var sql = "alter table \(self.name) add \(colume.name) \(colume.type.rawValue)"

        if colume.primaryKey{
            sql += " primary key "
        }
        
        if colume.unique{
            sql += " unique "
        }
        
        if colume.nullable == false && colume.defaultValue != nil{
            sql += " NOT NULL DEFAULT \(colume.defaultValue!)"
        }
        if let fk = colume.foreignDeclare{
            sql += (" " + fk.alterCode)
        }
        db.exec(sql: sql)
    }
    public func rename(fromcolume:String,to:String,db:DataBase){
        let sql = "alter table \(self.name) rename \(fromcolume) to \(to)"

        db.exec(sql: sql)
    }
    public func remove(colume:String,db:DataBase){
        let sql = "alter table \(self.name) drop \(colume)"

        db.exec(sql: sql)
    }
    public var code:String{
        let pk = self.primaryColume
        let fk = self.foreignColume.map({$0.foreignDeclare!.code})
        let pkv = self.pkCode
        let fkv = "," + fk.joined(separator: ",")
        var code = "create table if not exists \(name) (\(self.declare.map({$0.code}).joined(separator: ","))"
        if(pk.count > 0){
             code += pkv
        }
        if(fk.count > 0){
            code += fkv
        }
        return code + ")"
    }
    public func create(db:DataBase) throws {
        let rs = try db.prepare(sql: self.code)
        defer{
            rs.close()
        }
        _ = try rs.step()
    }
    private var pkCode:String{
        let pk = self.primaryColume
        if pk.count == 1 && pk.first!.autoInc{
            return ",PRIMARY KEY(\(pk.first!.name) AUTOINCREMENT)"
        }else if pk.count > 0{
            return ",PRIMARY KEY(\(pk.map({"\"\($0.name)\""}).joined(separator: ",")))"
        }else{
            return ""
        }
    }
    public func tableDeclare(from:DataBase) throws->String{
        return try TableDeclare.queryTableDeclare(from: from, name: self.name)
    }
    public static func queryTableDeclare(from:DataBase,name:String)throws->String{
        let sql = "select sql from sqlite_master where type=\"table\" AND name = \"\(name)\""
        let rs = try from.prepare(sql: sql)
        defer{
            rs.close()
        }
        if try rs.step() == .hasColumn{
            return rs.columeString(index: 0)
        }
        return ""
    }
}

/// 表列定义
public class TableColumn:CollumnDeclare{
    public var origin:DBType
    public init(value:DBType,type:CollumnDecType,nullable:Bool, name:String, primaryKey:Bool,unique:Bool,autoInc:Bool){
        self.origin = value
        super.init(type: type, nullable: nullable, name: name, primaryKey: primaryKey, unique: unique, defaultValue: value.asDefault, autoInc: autoInc)
    }
    public func asignOrigin(origin:DBType){
        self.origin = origin
    }
}

/// 表数据模型
public struct TableModel{
    public var name:String
    public var declare:[TableColumn]
    public var insertCode:String{
        "insert into \(self.name) (\(declare.filter({$0.autoInc == false}).map({$0.name}).joined(separator: ","))) values(\(declare.filter({$0.autoInc == false}).map({"@" + $0.name}).joined(separator: ",")))"
    }
    public var updateCode:String{
        "update `\(self.name)` set \(self.declare.filter({$0.autoInc == false}).map({"\($0.name)=@\($0.name)"}).joined(separator: ",")) " + primaryCondition
    }
    public var primaryCondition:String{
        if !self.hasPrimary{
            return ""
        }
        return "where " + self.primaryColume.map({"\($0.name)=@p\($0.name)"}).joined(separator: "and")
    }
    public var querykeys:[String]{
        self.declare.map({$0.name})
    }
    public var selectCode:String{
        let key = self.querykeys.joined(separator: ",")
        return "select \(key) from \(self.name) " + self.primaryCondition
    }
    public var primaryColume:[TableColumn]{
        self.declare.filter({$0.primaryKey})
    }
    public var hasPrimary:Bool{
        return self.primaryColume.count > 0
    }
    public func bindPrimaryConditionData(rs:DataBase.ResultSet) throws{
        for i in  self.primaryColume{
            let index = rs.getParamIndexBy(name: "@p"+i.name)
            try rs.bind(index: index, value: i.origin, type: i.type)
        }
    }
    public func insert(db:DataBase) throws {
        let rs = try db.prepare(sql: self.insertCode)
        defer{
            rs.close()
        }
        for i in self.declare{
            if i.autoInc == false{
                let indx = rs.getParamIndexBy(name: "@"+i.name)
                try rs.bind(index: indx, value: i.origin, type: i.type)
            }
        }
        _ = try rs.step()
       
    }
    public func update(db:DataBase) throws {
        if self.hasPrimary{
            let rs = try db.prepare(sql: self.updateCode)
            defer{
                rs.close()
            }
            for i in self.declare{
                if i.autoInc == false{
                    let indx = rs.getParamIndexBy(name: "@"+i.name)
                    try rs.bind(index: indx, value: i.origin, type: i.type)
                }
            }
            try self.bindPrimaryConditionData(rs: rs)
            _ = try rs.step()
            
        }else{
            throw NSError(domain: "model don't has primary key", code: 5)
        }
    }
    public func count(db:DataBase) throws->Int64 {
        let sql = "select count (*) from \(self.name)"
        let rs = try db.prepare(sql: sql)
        defer{
            rs.close()
        }
        _ = try rs.step()
        return rs.columeInt64(index: 0)
    }
    public func InDB(db:DataBase) throws->Bool {
        if(!self.hasPrimary){
            throw NSError(domain: "no exist primary key", code: 0)
        }
        let sql = "select count (*) from \(self.name)" + self.primaryCondition
        let rs = try db.prepare(sql: sql)
        defer{
            rs.close()
        }
        _ = try rs.step()
        return rs.columeInt64(index: 0) > 0
    }
    public func select(db:DataBase) throws{
        let map = self.declare.reduce(into: [:]) { partialResult, tc in
            partialResult[tc.name] = tc
        }
        let rs = try db.prepare(sql: self.selectCode)
        defer{
            rs.close()
        }
        try self.bindPrimaryConditionData(rs: rs)
        while try rs.step() == .hasColumn{
            for i in 0 ..< rs.columeCount{
                let name = rs.columeName(index: i)
                if let v:DBType = DataBaseObject.colume(rs:rs, index: i){
                    map[name]?.origin = v
                }
            }
        }
        for i in 0 ..< rs.columeCount{
            let name = rs.columeName(index: i)
            if let v:DBType = DataBaseObject.colume(rs:rs, index: i){
                map[name]?.origin = v
            }
        }
    }
    public func delete(db:DataBase) throws{
        let rs = try db.prepare(sql: "delete from \(self.name) \(self.primaryCondition)")
        defer{
            rs.close()
        }
        try self.bindPrimaryConditionData(rs: rs)
        _ = try rs.step()
        
    }
    
    public static func bind(rs:DataBase.ResultSet, param:[String:DBType]) throws{
        for i in param {
            try rs.bind(name: i.key, value: i.value)
        }
    }
    
    public static func select(db:DataBase,
                              keys:[String],
                              table:String,
                              condition:QueryCondition? = nil,
                              param:[String:DBType]? = nil) throws -> [TableModel]{
        let select = "select \(keys.joined(separator: ",")) from \(table)" + (condition == nil ? "" : " where \(condition!.condition)")
        let rs = try db.prepare(sql: select)
        defer{
            rs.close()
        }
        if let p = param{
            try self.bind(rs: rs, param: p)
        }
        var models:[TableModel] = []
        while try rs.step() == .hasColumn {
            var a:[TableColumn] = []
            for i in 0 ..< rs.columeCount{
                if let c:DBType = DataBaseObject.colume(rs:rs, index: i){
                    let tc = TableColumn(value: c, type: rs.columeDecType(index: i) ?? .textDecType, nullable: false, name: rs.columeName(index: i), primaryKey: false, unique: false,autoInc:false)
                    a.append(tc)
                }
            }
            models.append(TableModel(name: table, declare: a))
        }
        
        return models
    }
    public func drop(db:DataBase){
        db.exec(sql: "drop table \(self.name)")
    }
    public static func delete(db:DataBase,table:String,condition:QueryCondition,param:[String:DBType]? = nil) throws{
        let sql = "delete from \(table) where \(condition.condition)"
        
        let rs = try db.prepare(sql: sql)
        defer{
            rs.close()
        }
        if let p = param{
            try self.bind(rs: rs, param: p)
        }
        _ = try rs.step()
        
    }
}

/// 查询条件
public class QueryCondition{
    public var condition:String
    public init(condition:String){
        self.condition = condition
    }
    public static func between(key:Key,value1:DBType,value2:DBType)->QueryCondition{
        QueryCondition(condition:"\(key.key) between \(value1) and \(value2)")
    }
    public static func like(key:Key,value:String)->QueryCondition{
        QueryCondition(condition:"\(key.key) like \(value)")
    }
    public static func `in`(key:Key,value:[DBType])->QueryCondition{
        QueryCondition(condition:"\(key.key) in (\(value.map({$0.stringValue}).joined(separator: ",")))")
    }
    public static func Not (condition:QueryCondition)->QueryCondition{
        QueryCondition(condition:"NOT \(condition.condition)")
    }
    public static func &&(l:QueryCondition,r:QueryCondition)->QueryCondition{
        QueryCondition(condition: l.condition+" and "+r.condition)
    }
    public static func ||(l:QueryCondition,r:QueryCondition)->QueryCondition{
        QueryCondition(condition: l.condition+" or "+r.condition)
    }
    public struct Key{
        public var key:String
        public init(key:String,table:DataBaseProtocol.Type? = nil){
            self.key = table == nil ? key : (table!.name + ".") + key
        }
        
        // json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$') → '{"a":2,"c":[4,5,{"f":7}]}'
        // json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.c') → '[4,5,{"f":7}]'
        // json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.c[2]') → '{"f":7}'
        // json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.c[2].f') → 7
        // json_extract('{"a":2,"c":[4,5],"f":7}','$.c','$.a') → '[[4,5],2]'
        // json_extract('{"a":2,"c":[4,5],"f":7}','$.c[#-1]') → 5
        // json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.x') → NULL
        // json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.x', '$.a') → '[null,2]'
        // json_extract('{"a":"xyz"}', '$.a') → 'xyz'
        // json_extract('{"a":null}', '$.a') → NULL
        
        public init(jsonKey:String,keypath:String,table:DataBaseProtocol.Type? = nil){
            let key = table == nil ? jsonKey : (table!.name + ".") + jsonKey
            self.key = "json_extract(\(key),'\(keypath)')"
        }
        public static func ==(l:QueryCondition.Key,r:QueryCondition.Key)->QueryCondition{
            QueryCondition(condition: l.key + " = " + r.key)
        }
        public static func >=(l:QueryCondition.Key,r:QueryCondition.Key)->QueryCondition{
            QueryCondition(condition: l.key + " >= " + r.key)
        }
        public static func <=(l:QueryCondition.Key,r:QueryCondition.Key)->QueryCondition{
            QueryCondition(condition: l.key + " <= " + r.key)
        }
        public static func >(l:QueryCondition.Key,r:QueryCondition.Key)->QueryCondition{
            QueryCondition(condition: l.key + " > " + r.key)
        }
        public static func <(l:QueryCondition.Key,r:QueryCondition.Key)->QueryCondition{
            QueryCondition(condition: l.key + " < " + r.key)
        }
        public static func !=(l:QueryCondition.Key,r:QueryCondition.Key)->QueryCondition{
            QueryCondition(condition: l.key + " <> " + r.key)
        }
    }
}

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
    
    public static func select<T:DataBaseProtocol>(db:DataBase,condition:QueryCondition? = nil,param:[String:DBType]? = nil) throws ->[T]{
        
        try TableModel.select(db: db,keys: T().declare.querykeys,table: self.name, condition: condition,param: param).map { tm in
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
    fileprivate static func databaseVersion(db:DataBase) throws ->Version{
        do{
            if let v = try Version.versionOf(db: db, tableName: self.name){
                return v
            }
            
        }catch{
            try Version().declare.create(db: db)
        }
        let v = Version()
        v.tableName = self.name
        v.versionNum = Int(Self().version)
        try v.tableModel.insert(db: db)
        return v
    }
    public static func databaseVersionNum(db:DataBase) throws ->Int{
        return try self.databaseVersion(db: db).versionNum 
    }
    public static func createTable(update:DataBaseUpdate?,db:DataBase) throws {
        if try db.tableExist(name: self.name){
            let ver = try databaseVersion(db: db)
            let last = try update?.update(db: db,model: Self.self)
            if(last != nil && last! > 0 && ver.versionNum < last!){
                ver.versionNum = Int(last!)
                try ver.tableModel.update(db: db)
            }
        }else{
            try Self.init().declare.create(db: db)
            let v = try self.databaseVersion(db: db)
            v.versionNum = Int(Self.init().version)
            try v.tableModel.update(db: db)
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
                refTable:DataBaseProtocol.Type? = nil,
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

fileprivate struct Version:DataBaseProtocol{
    public init() {}
    
    public init(db: DataBase) throws {
        try Version.createTable(update: self.updates, db: db)
    }
    
    public static var name: String = "version"
    
    public var updates: DataBaseUpdate?
    
    @Col(name:"id",primaryKey:true,autoInc:true)
    public var tbId:Int = 0
    
    @Col(name:"tableName")
    public var tableName:String = ""
    
    @Col(name:"versionNum")
    public var versionNum:Int = 0
    
    
    public static func versionOf(db:DataBase,tableName:String) throws ->Version?{
        let v:[Version] = try Version.select(db: db, condition: QueryCondition(condition: "tableName = \'\(tableName)\'"))
        return v.first
    }
}


