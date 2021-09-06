//
//  Mirror.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/24.
//


import Foundation


public protocol OriginValue{
    static var sqlType:String { get }
    var sqlType:String { get }
}

public protocol SqlType{
    var sqlType:String { get }
    var primaryKey:Bool { get }
    var remoteTable:String? { get }
    var remoteKey:String? { get }
    var keyName:String? { get }
    var nullable:Bool { get }
    var defaultValue:String? { get }
    var onDelete:ForeignKeyAction? { get }
    var onUpdate:ForeignKeyAction? { get }
    var value:OriginValue? { get }
    var path:AnyKeyPath? { get }
}
extension OriginValue{
    public var nullType:String{
        self.sqlType.components(separatedBy: " ").first!
    }
    public static var nullType:String{
        self.sqlType.components(separatedBy: " ").first!
    }
}
extension Int:OriginValue {
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
}
extension Int32:OriginValue {
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
}
extension Int64:OriginValue {

    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
}
extension Bool:OriginValue {
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
}

extension String:OriginValue {
    public var sqlType:String{
        return "TEXT NOT NULL"
    }
    public static var sqlType:String{
        return "TEXT NOT NULL"
    }
}
extension Data:OriginValue {
    public var sqlType:String{
        return "BLOB NOT NULL"
    }
    public static var sqlType:String{
        return "BLOB NOT NULL"
    }
}

extension Double:OriginValue {

    public var sqlType:String{
        return "REAL NOT NULL"
    }
    public static var sqlType:String{
        return "REAL NOT NULL"
    }
}
extension Float:OriginValue {
    public var sqlType:String{
        return "REAL NOT NULL"
    }
    public static var sqlType:String{
        return "REAL NOT NULL"
    }
}
@propertyWrapper
public struct Unique<T:SqlType>:SqlType,CustomDebugStringConvertible{
    public var defaultValue: String?{
        wrappedValue.defaultValue
    }
    
    public var debugDescription: String{
        "\(wrappedValue)"
    }
    public var nullable: Bool{
        wrappedValue.nullable
    }
    public var path: AnyKeyPath? {
        return wrappedValue.path
    }
    public var value: OriginValue? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType + " UNIQUE"
    }
    
    public var wrappedValue:T
    public init(wrappedValue:T){
        self.wrappedValue = wrappedValue
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String? {
        return wrappedValue.keyName
    }
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct PrimaryKey<T:SqlType>:SqlType,CustomDebugStringConvertible{
    public var defaultValue: String?{
        wrappedValue.defaultValue
    }
    public var nullable: Bool{
        wrappedValue.nullable
    }
    public var debugDescription: String{
        "\(wrappedValue)"
    }
    public var path: AnyKeyPath? {
        return wrappedValue.path
    }
    public var value: OriginValue? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    
    public var wrappedValue:T
    public init(wrappedValue:T){
        self.wrappedValue = wrappedValue
    }
    public var primaryKey: Bool {
        true
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String? {
        return wrappedValue.keyName
    }
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct Default<T:SqlType>:SqlType,CustomDebugStringConvertible{
    

    public var nullable: Bool{
        wrappedValue.nullable
    }
    
    public var debugDescription: String{
        "\(wrappedValue)"
    }
    public var path: AnyKeyPath? {
        return wrappedValue.path
    }
    public var value: OriginValue? {
        wrappedValue.value
    }
    
    public var sqlType: String{
        wrappedValue.sqlType + "  DEFAULT \(self.defaultValue!)"
    }
    public var wrappedValue:T
    public var defaultValue:String?
    public init(wrappedValue:T, _ value:String){
        self.wrappedValue = wrappedValue
        self.defaultValue = value
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String? {
        return wrappedValue.keyName
    }
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct Key<T:SqlType>:SqlType,CustomDebugStringConvertible{
    public var debugDescription: String{
        "\(wrappedValue)"
    }
    public var defaultValue: String?{
        wrappedValue.defaultValue
    }
    public var nullable: Bool{
        wrappedValue.nullable
    }
    public var path: AnyKeyPath?{
        return wrappedValue.path
    }
    public var value: OriginValue? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    
    
    public var wrappedValue:T
    public init(wrappedValue:T,_ name:String){
        self.wrappedValue = wrappedValue
        self.keyName = name
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String?
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct Column<T:OriginValue>:SqlType,CustomDebugStringConvertible{
    public var debugDescription: String{
        "\(wrappedValue)"
    }
    public var defaultValue: String?{
        nil
    }
    public var path: AnyKeyPath?
    public var value: OriginValue? {
        return self.wrappedValue
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    public var nullable: Bool{
        return false
    }
    
    public var wrappedValue:T
    public init(wrappedValue:T,_ keyPath:AnyKeyPath){
        self.wrappedValue = wrappedValue
        self.path = keyPath
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        nil
    }
    
    public var remoteKey: String? {
        nil
    }
    public var keyName: String?{
        nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
@propertyWrapper
public struct NullableColumn<T:OriginValue>:SqlType,CustomDebugStringConvertible{
    public var nullable: Bool{
        return true
    }
    public var defaultValue: String?{
        nil
    }
    public var debugDescription: String{
        "\(String(describing: wrappedValue))"
    }
    public var path: AnyKeyPath?
    public var value: OriginValue? {
        wrappedValue
    }
    public var sqlType: String{
        wrappedValue?.nullType ?? T.nullType
    }
    
    
    public var wrappedValue:T?
    public init(wrappedValue:T?,_ keyPath:AnyKeyPath){
        self.wrappedValue = wrappedValue
        self.path = keyPath
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        nil
    }
    
    public var remoteKey: String? {
        nil
    }
    public var keyName: String?{
        nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}


@propertyWrapper
public struct ForeignKey<T:SqlType>:SqlType{
    public var defaultValue: String?{
        wrappedValue.defaultValue
    }
    
    public var path: AnyKeyPath? {
        return wrappedValue.path
    }
    public var value: OriginValue? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    public var nullable: Bool{
        wrappedValue.nullable
    }
    public var wrappedValue:T
    public var remoteTable: String?
    public var onDelete: ForeignKeyAction?
    public var onUpdate: ForeignKeyAction?
    public var remoteKey: String?
    public init(wrappedValue:T,
                remoteTable:String,
                remoteKey:String,
                onDelete:ForeignKeyAction? = nil,
                onUpdate:ForeignKeyAction? = nil){
        self.wrappedValue = wrappedValue
        self.remoteTable = remoteTable
        self.remoteKey = remoteKey
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    
    public var keyName: String? {
        return wrappedValue.keyName
    }
    
}



extension SQLCode{
    
    public var columnMap:[(label:String,value:SqlType)]{
       
        var array = self.mirrorToMap(mirror: Mirror(reflecting: self))
        var m = Mirror(reflecting: self).superclassMirror
        while let a = m {
            array.append(contentsOf: self.mirrorToMap(mirror: a))
            m = a.superclassMirror
        }
        return array
    }
    private func mirrorToMap(mirror:Mirror)->[(label:String,value:SqlType)]{
        mirror.children.filter({$0.value is SqlType}).map { i in
            let label = i.label!
            let lab = label.starts(with: "_") ? String(label[label.index(after: label.startIndex) ..< label.endIndex]) : label
            return (label:lab,value:i.value as! SqlType)
        }
    }
    
    public var create:String{
        let columnMap = self.columnMap
        
        var item = columnMap.map { i in
            "`\(i.value.keyName ?? i.label)` \(i.value.sqlType)"
        }
        if item.count == 0{
            return ""
        }
        let fitem = columnMap.filter { i in
            i.value.remoteTable != nil && i.value.remoteKey != nil
        }.map { i -> String in
            var code = "FOREIGN KEY(`\(i.value.keyName ?? i.label)`) REFERENCES `\(i.value.remoteTable!)`(`\(i.value.remoteKey!)`)"
            if let action = i.value.onUpdate{
                code += " ON UPDATE \(action.action) "
            }
            if let action = i.value.onDelete{
                code += " ON DELETE \(action.action) "
            }
            return code
        }

        let pkItem = columnMap.filter { i in
            i.value.primaryKey
        }.map { i in
            "`\(i.value.keyName ?? i.label)`"
        }.compactMap({$0})
        if(pkItem.count > 0){
            let pk = "PRIMARY KEY(" + pkItem.joined(separator: ",") + ")"
            
            item.append(pk)
        }
        if(fitem.count > 0){
            item.append(contentsOf: fitem)
        }

        return "CREATE TABLE IF NOT EXISTS  `\(Self.tableName)` (" + item.joined(separator: ",") + ")"
    }
    public var primaryKey:[(String,SqlType)]{
        self.columnMap.filter { i in
            i.value.primaryKey
        }.filter { i in
            i.value.value != nil
        }
    }
    public var normalKey:[(String,SqlType)] {
        self.columnMap.filter({$0.value.value != nil})
    }
    public var fullKey:[(String,SqlType)] {
        self.columnMap.map({($0.label,$0.value)})
    }
    public static func insertKeyCode(_ i: (String, SqlType)) -> String {
        if i.1.value is Data{
            return "@\(i.0)"
        }else if i.1.value is String{
            return "@\(i.0)"
        }else{
            return "\(i.1.value!)"
        }
    }
    
    var allValueKey:String{
        return self.normalKey.map { i -> String in
            return Self.insertKeyCode(i)
        }.joined(separator: ",")
    }
    var insert:String{
        let key = self.normalKey.map({$0.1.keyName ?? $0.0}).joined(separator: ",")
        
        return "INSERT INTO `\(Self.tableName)` (\(key)) values(\(self.allValueKey))"
    }
    var bindMap:[String:SqlType]{
        self.fullKey.filter { i in
            i.1.value == nil || (i.1.value is Data || i.1.value is String)
        }.reduce(into: [:]) { r, i in
            r[i.0] = i.1
        }
    }
    func doInsert(db:Database) throws{
        let result = try db.query(sql: self.insert)
        self.doBind(resultSet: result)
        try result.step()
        result.close()
    }
    public static func updateSetKeyCode(_ i: (String,String, OriginValue?)) -> String? {
        let key = i.0
        if i.2 is Data{
            return "\(key) = @\(i.1)"
        }else if i.2 is String{
            return "\(key) = @\(i.1)"
        }else if i.2 == nil{
            return "\(key) = @\(i.1)"
        }else{
            return "\(key) = \(i.2!)"
        }
    }
    
    var update:String{
        let value = self.fullKey.map { i -> String? in
            return Self.updateSetKeyCode((i.1.keyName ?? i.0,i.0,i.1.value))
        }.compactMap({$0}).joined(separator: ",")
        if self.primaryKey.count == 0{
            return ""
        }else{
            return "UPDATE \(Self.tableName) SET \(value) where \(self.primaryCondition)"
        }
    }
    
    func doUpdate(db:Database) throws{
        let result = try db.query(sql: self.update)
        self.doBind(resultSet: result)
        try result.step()
        result.close()
    }
    var delete:String{
        if self.primaryKey.count == 0{
            return ""
        }
        return "DELETE FROM \(Self.tableName) where \(self.primaryCondition)"
    }
    func doDelete(db:Database) throws{
        let result = try db.query(sql: self.delete)
        self.doBind(resultSet: result)
        try result.step()
        result.close()
    }
    
    public static func conditionCode(_ i: (String, SqlType)) -> String {
        let key = i.1.keyName ?? i.0
        if i.1.value is Data{
            return "\(key) = @\(i.0)"
        }else if i.1.value is String{
            return "\(key) = @\(i.0)"
        }else{
            return "\(key) = \(i.1.value!)"
        }
    }
    
    var primaryCondition:String{
        if(self.primaryKey.count > 0){
            return self.primaryKey.map { i in
                return Self.conditionCode(i)
            }.joined(separator: " AND ")
        }else{
            return ""
        }
    }
    var primaryConditionBindMap:[String:OriginValue]{
        return self.primaryKey.filter { i in
            i.1.value != nil && (i.1.value is Data || i.1.value is String)
        }.reduce(into: [:]) { r, k in
            r[k.0] = k.1.value!
        }
    }
    func doBind(resultSet:Database.ResultSet){
        for i in self.bindMap {
            if i.value.value is String{
                resultSet.bind(name: "@"+i.key)?.bind(value: i.value.value as! String)
            }else if i.value.value is Data{
                resultSet.bind(name: "@"+i.key)?.bind(value: i.value.value as! Data)
            }else if i.value.value == nil {
                resultSet.bindNull(name: "@"+i.key)
            }
        }
    }
}

extension Database {
    public func fetch<T:SQLCode>(request:FetchRequest<T>) throws->ResultSet{
        let rs = try self.query(sql: request.sql)
        request.doSelectBind(result: rs)
        return rs
    }

    public func create<T:SQLCode>(obj:T) throws{
        if try self.tableExists(name: T.tableName){
            let column = try self.tableInfo(name: T.tableName)
            let nowColumn = T().fullKey
            let addC = nowColumn.filter { i in
                !column.contains { j in
                    (i.1.keyName != nil && j.key == i.1.keyName!) || i.0 == j.key
                }
            }
            for i in addC {
                guard let t = i.1.value else { throw NSError(domain: "alter table value is not use", code: 0, userInfo: nil) }
                try self.addColumn(name: T.tableName, columeName: i.1.keyName ?? i.0, ov:t , notnull: i.1.nullable, defaultValue: i.1.defaultValue ?? "null")
            }
            let removeC = column.filter { j in
                !nowColumn.contains(where: { i in
                    (i.1.keyName != nil && j.key == i.1.keyName!) || i.0 == j.key
                })
            }
            if removeC.count > 0{
                self.foreignKey = false
                try self.alterTableName(name: T.tableName, newName: "\(T.tableName)_temp");
                try self.exec(sql: obj.create)
                let key = obj.fullKey.map({$0.1.keyName ?? $0.0}).joined(separator: ",")
                let copySql = "INSERT INTO \(T.tableName)  SELECT \(key) FROM \("\(T.tableName)_temp")"
                try self.exec(sql: copySql)
                try self.exec(sql: "drop table \(T.tableName)_temp")
                self.foreignKey = true
                print(try self.integrityCheck(table: T.tableName))
                
            }
        
        }else{
            try self.exec(sql: obj.create)
        }
    }
    public func addColumn<T:OriginValue>(name:String,columeName:String,type:T.Type,notnull :Bool = false ,defaultValue:String = "") throws {
        let typedef = notnull ? T.sqlType : T.nullType
        try self.addColumn(name: name, columeName: columeName, typedef: typedef,notnull: notnull,defaultValue: defaultValue)
    }
    public func addColumn(name:String,columeName:String, ov:OriginValue ,notnull:Bool = false ,defaultValue:String = "") throws {
        let typedef = notnull ? ov.sqlType : ov.nullType
        try self.addColumn(name: name, columeName: columeName, typedef: typedef,notnull: notnull,defaultValue: defaultValue)
    }
    
    public func alterTableName(name:String,newName:String) throws {
        let sql = "ALTER TABLE \(name) RENAME TO \(newName)"
        try self.exec(sql: sql)
    }
    public func renameColumn(name:String,columeName:String,newName:String) throws {
        try self.exec(sql: "ALTER TABLE \(name) RENAME COLUMN \(columeName) TO \(newName)")
    }
    public func exists<T:SQLCode>(model:T) throws ->Bool{
        let req = FetchRequest(obj: model,key:.count("*"))
        req.loadKeyMap(map: model.primaryConditionBindMap)
        let r = try self.query(sql: req.sql)
        req.doSelectBind(result: r)
        try r.step()
        let c = r.column(index: 0, type: Int32.self).value() > 0
        r.close()
        return c
    }
    public func save<T:SQLCode>(model:T) throws{
        if try self.exists(model: model){
            try self.update(model: model)
        }else{
            try self.insert(model: model)
        }
    }
    public func count<T:SQLCode>(model:T.Type) throws ->Int{
        let req = FetchRequest(table: model, key: .count("*"))
        let r = try self.query(sql: req.sql)
        try r.step()
        let c = r.column(index: 0, type: Int.self).value()
        r.close()
        return c
    }
    public func update<T:SQLCode>(model:T) throws {
        try model.doUpdate(db: self)
    }
    public func update<T:SQLCode>(model:[String:OriginValue?],table:T.Type,condition:Condition,bind:[String:OriginValue] = [:]) throws {
        let kv = model.map { i in
            T.updateSetKeyCode((i.key,i.key,i.value))
        }.compactMap({$0}).joined(separator: ",")
        let c = "UPDATE \(T.tableName) SET \(kv) where \(condition.conditionCode)"
        let rs = try self.query(sql: c)
        for i in model{
            
            if i.value is Data{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
            }else if i.value is String{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
            }
        }
        for i in bind{
            if i.value is Data{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
            }else if i.value is String{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
            }
        }
        try rs.step()
        rs.close()
    }
    public func delete<T:SQLCode>(table:T.Type,condition:Condition,bind:[String:OriginValue]) throws {
        let c = "DELETE FROM \(T.tableName) where \(condition.conditionCode)"
        let rs = try self.query(sql: c)
        for i in bind{
            if i.value is Data{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
            }else if i.value is String{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
            }
        }
        try rs.step()
        rs.close()
    }
    public func select<T:SQLCode>(request:FetchRequest<T>) throws ->[T]{
        let s = try self.fetch(request: request)
        let re = try FetchRequest<T>.readData(resultset: s)
        return re
    }
    public func select<T:SQLCode>(model:T) throws ->T?{
        let r = FetchRequest(obj: model, key: .all)
        r.loadKeyMap(map: model.primaryConditionBindMap)
        let s = try self.fetch(request: r)
        
        let re = try FetchRequest<T>.readData(resultset: s).first
        return re
    }
    public func select<T:SQLCode>(type:T.Type,key:FetchKey) throws ->T?{
        let r = FetchRequest(table: type, key: key)
        let s = try self.fetch(request: r)
        
        let re = try FetchRequest<T>.readData(resultset: s).first
        return re
    }
    public func delete<T:SQLCode>(model:T) throws {
        try model.doDelete(db: self)
    }
    public func insert<T:SQLCode>(model:T) throws{
        try model.doInsert(db: self)
    }
    public func drop<T:SQLCode>(modelType:T.Type) throws{
        try self.exec(sql: "drop table if exists `\(T.tableName)`")
    }
}

