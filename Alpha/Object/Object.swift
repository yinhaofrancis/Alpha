//
//  Object.swift
//  Alpha
//
//  Created by hao yin on 2021/9/9.
//

import Foundation

public struct DataMode: OptionSet {
    public let rawValue: UInt8
    public var defaultValue:String?
    public static let none = DataMode([])
    public static let primary = DataMode(rawValue: 1 << 0)
    public static let notnull = DataMode(rawValue: 1 << 1)
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
public enum DataTypeDef {
    case integer
    case double
    case text
    case blob
    public var define:String{
        switch self {
        
        case .integer:
            return "INTEGER"
        case .double:
            return "REAL"
        case .text:
            return "TEXT"
        case .blob:
            return "BLOB"
        }
    }
}
public protocol DataType{
    var define:DataTypeDef { get }
    func bind(rs:Database.ResultSet,key:String)
    mutating func colume(rs:Database.ResultSet,key:String)
    func bind(rs:Database.ResultSet,index:Int32)
    mutating func  colume(rs:Database.ResultSet,index:Int32)
}
extension Optional:DataType where Wrapped == DataType {
    public var define: DataTypeDef {
        switch self {
        case .none:
            return .text
        case let .some(v):
            return v.define
        }
    }
    
    public func bind(rs: Database.ResultSet, key: String) {
        switch self {
        case .none:
            return rs.bindNull(name: key)
        case let .some(v):
            return v.bind(rs: rs, key: key)
        }
    }
    
    public mutating func colume(rs: Database.ResultSet, key: String) {
        self?.colume(rs: rs, index: rs.index(paramName: key))
    }
    
    public func bind(rs: Database.ResultSet, index: Int32) {
        switch self {
        case .none:
            return rs.bindNull(index: index)
        case let .some(v):
            return v.bind(rs: rs, index:index)
        }
    }
    
    public mutating func colume(rs: Database.ResultSet, index: Int32) {
        switch self {
        case .none:
           return
        case .some:
            let v = rs.column(index: index, type: Wrapped.self)
            self = .some(v as! DataType)
        }
    }
    
    
}
extension String:DataType{
    public func bind(rs: Database.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, index: Int32) {
        self.removeAll()
        self.append(rs.column(index: index, type: Self.self).value())
    }
    
    public func bind(rs: Database.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, key: String) {
        self.removeAll()
        self.append(rs.column(index: rs.index(paramName: key), type: Self.self).value())
    }
    
    public var define: DataTypeDef{
        return .text
    }
}
extension Int:DataType{
    public var define: DataTypeDef{
        return .integer
    }
    public func bind(rs: Database.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, index: Int32) {
        let i = rs.column(index: index, type: Self.self).value()
        self = i
    }
    
    public func bind(rs: Database.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, key: String) {
        self = rs.column(index: rs.index(paramName: key), type: Self.self).value()
    }
    
}
extension Double:DataType{
    public var define: DataTypeDef{
        return .double
    }
    public func bind(rs: Database.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, index: Int32) {
        let i = rs.column(index: index, type: Self.self).value()
        self = i
    }
    
    public func bind(rs: Database.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, key: String) {
        self = rs.column(index: rs.index(paramName: key), type: Self.self).value()
    }
}
extension Data:DataType{
    public var define: DataTypeDef{
        return .blob
    }
    public func bind(rs: Database.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, index: Int32) {
        self.removeAll()
        self.append(rs.column(index: index, type: Self.self).value())
    }
    
    public func bind(rs: Database.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
    
    public mutating func colume(rs: Database.ResultSet, key: String) {
        self.removeAll()
        self.append(rs.column(index: rs.index(paramName: key), type: Self.self).value())
    }
}

public protocol ColDef{
    var mode:DataMode { get  }
    var define:DataType { get }
}
extension ColDef{
    public var defineCode:String{
        return self.define.define.define + "\(self.mode.contains(.notnull) ? "not null" : "")" + "\(self.mode.defaultValue == nil ? "" : "default \(self.mode.defaultValue!)")"
    }
}
struct InnerDef:ColDef {
    var mode: DataMode
    
    var define: DataType
}
@propertyWrapper
public struct Col<T:DataType>:ColDef{
    public var define: DataType{
        return self.wrappedValue
    }
    public var mode:DataMode
    public var wrappedValue:T
    public init(wrappedValue:T,_ mode:DataMode = [.none],_ defaultValue:String? = nil) {
        self.wrappedValue = wrappedValue
        self.mode = mode
        self.mode.defaultValue = defaultValue
    }
}

@propertyWrapper
public struct NullableCol<T:DataType>:ColDef{
    public var define: DataType{
        return self.wrappedValue ?? nil
    }
    public var mode:DataMode
    public var wrappedValue:T?
    public init(wrappedValue:T?,_ mode:DataMode = [.none],_ defaultValue:String? = nil) {
        self.wrappedValue = wrappedValue
        self.mode = mode
        self.mode.defaultValue = defaultValue
    }
}

@objcMembers public class Object:NSObject{
    public var rowid:Int = 0
    public var name:String{
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
    public var keyCol:[String:ColDef]{
        return Object.classKeyCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public var primaryKeyCol:[String:ColDef]{
        return Object.classKeyPrimaryCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public var normalKeyCol:[String:ColDef]{
        return Object.classKeyNormalCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public static func classKeyCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        var c:UInt32 = 0
        if cls == Self.self{
            return [:]
        }
        let propertys = class_copyPropertyList(cls, &c)
        let km = mirror.children.reduce(into: [:]) { r, kv in
            guard let label = kv.label else { return }
            r[label] = kv.value
        }
        var keymap:[String:ColDef]
        if let sc = cls.superclass() , let sm = mirror.superclassMirror{
            keymap = self.classKeyCol(cls: sc, mirror: sm)
        }else{
            keymap = [:]
        }
        for i in 0 ..< c{
            guard let p = propertys?.advanced(by: Int(i)).pointee else{
                continue
            }
            let name = String(cString: property_getName(p))
            guard let type = property_copyAttributeValue(p, "T") else { continue }
            let pro = String(cString:type)
            if let wrapInfo = km["_" + name]{
                keymap[name] = wrapInfo as? ColDef
            }else{
                if keymap[name] != nil{
                    if pro == "c" || pro == "s" || pro == "i" || pro == "q" || pro == "C" || pro == "S" || pro == "I" || pro == "Q"{
                        
                        keymap[name] = InnerDef(mode: .none, define: (self.value(forKey: name) as! NSNumber).intValue)
                    }else if pro == "f" || pro == "d"{
                        keymap[name] = InnerDef(mode: .none, define: (self.value(forKey: name) as! NSNumber).doubleValue)
                    }else if pro == "NSData"{
                        keymap[name] = InnerDef(mode: .none, define:  self.value(forKey: name) as! Data)
                    }else{
                        keymap[name] = InnerDef(mode: .none, define: self.value(forKey: name) as! String)
                    }
                }
            }
            type.deallocate()
        }
        propertys?.deallocate()
        return keymap
    }
    public static func classKeyPrimaryCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            i.value.mode == .primary
        }
    }
    public static func classKeyNormalCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            i.value.mode != .primary
        }
    }
    public var insertCode:String{
        let keys = self.keyCol.keys
        let a = "insert into `\(self.name)` (" + keys.joined(separator: ",") + ") values " + "(" + keys.map { i in
            "@" + i
        }.joined(separator: ",") + ")"
        return a
    }
    public var condition:String{
        let keys = self.primaryKeyCol.keys
        if keys.count == 0{
            return "rowid=\(self.rowid)"
        }else{
            return keys.map{$0 + "=" + "@" + $0}.joined(separator: " and ")
        }
        
    }
    public var updateCode:String{
        let keys = self.keyCol.keys
        return "update `\(self.name)` set " + keys.map { i in
            "\(i)=@\(i)"
        }.joined(separator: ",") + " where " + self.condition
    }
    public var createCode:String{
        let kcm = self.keyCol.map { i in
            i.key + " " + i.value.defineCode
        }
        let pk = self.primaryKeyCol.keys.count > 0 ? ["primary key(" + self.primaryKeyCol.keys.joined(separator: ",") + ")"] : []
        let kmp = (kcm + pk).joined(separator: ",")
        let sql = "create table if not exists`\(self.name)`" + "(\(kmp))"
        return sql
    }
    public var deleteCode:String{
        return "delete from `\(self.name)` where " + self.condition
    }
    public var selectCode:String{
        return "select *,rowid from `\(self.name)` where " + self.condition
    }
    public func result(rs:Database.ResultSet){
        let kv = self.keyCol
        for i in 0 ..< rs.columnCount{
            let name = rs.columnName(index: i)
            if rs.type(index: Int32(i)) == .Null{
                self.setValue(nil, forKey: name)
                continue
            }
            if(name == "rowid"){
                let v = rs.column(index: Int32(i), type: Int.self).value()
                self.setValue(v, forKey: name)
                continue
            }
            guard let define = kv[name]?.define.define else { continue }
            switch define {
            case .integer:
                let v = rs.column(index: Int32(i), type: Int.self).value()
                self.setValue(v, forKey: name)
            case .double:
                let v = rs.column(index: Int32(i), type: Double.self).value()
                self.setValue(v, forKey: name)
            case .text:
                let v = rs.column(index: Int32(i), type: String.self).value()
                self.setValue(v, forKey: name)
            case .blob:
                let v = rs.column(index: Int32(i), type: Data.self).value()
                self.setValue(v, forKey: name)
            }
            
        }
    }

    public func bind(rs:Database.ResultSet){
        for i in self.keyCol {
            i.value.define.bind(rs: rs, key: "@" + i.key)
            print("\(i.key)=\(i.value.define)")
        }
    }
    func writeDataCode(db:Database,sql:String) throws {
        let rs = try db.query(sql: sql)
        self.bind(rs: rs)
        try rs.step()
        rs.close()
    }
    public func queryModel<T:Object>(db:Database,sql:String,type:T.Type) throws ->[T] {
        let rs = try db.query(sql: sql)
        self.bind(rs: rs)
        var res:[T] = []
        while try rs.step(){
            let obj = T()
            obj.result(rs: rs)
            res.append(obj)
        }
        rs.close()
        return res
    }
    func readDataModel<T:Object>(db:Database,sql:String,object: inout T) throws {
        print(sql)
        let rs = try db.query(sql: sql)
        self.bind(rs: rs)
        if try rs.step() {
            object.result(rs: rs)
        }
        rs.close()
    }
    public func insert(db:Database) throws{
        try self.writeDataCode(db: db, sql: self.insertCode)
    }
    public func update(db:Database) throws{
        try self.writeDataCode(db: db, sql: self.updateCode)
    }
    public func delete(db:Database) throws{
        try self.writeDataCode(db: db, sql: self.deleteCode)
    }
    public func query(db:Database) throws{
        var a = self
        try self.readDataModel(db: db, sql: self.selectCode, object: &a)
    }
    public func create(db:Database) throws{
        if try db.tableExists(name: self.name) == false{
            try db.exec(sql: self.createCode)
            return
        }
        for i in try self.newkey(db: db){
            guard let def = self.keyCol[i]?.defineCode else { continue }
            try db.addColumn(name: self.name, columeName: i, typedef: def)
        }
    
        if try self.oldKey(db: db).count > 0{
            try db.alterTableName(name: self.name, newName: self.name + "_tmp")
            try db.exec(sql: self.createCode)
            let tmps = try db.tableInfo(name: self.name + "_tmp").keys
            let new = self.keyCol.keys
            let copyCol = tmps.filter({new.contains($0)})
            try db.copyTable(to: self.name, from: self.name + "_tmp", keys:copyCol)
            try db.drop(name:self.name + "_tmp")
        }
        
    }
    public func newkey(db:Database) throws ->[String]{
        let old = try db.tableInfo(name: self.name).keys
        return self.keyCol.keys.filter { i in
            old.contains(i) == false
        }
    }
    public func oldKey(db:Database) throws ->[String]{
        let old = try db.tableInfo(name: self.name).keys
        let new = self.keyCol.keys
        return old.filter { i in
            new.contains(i) == false
        }
    }
    public required override init() {
        super.init()
    }
}
public struct Page{
    public let offset:Int32
    public let limit:Int32
}
public enum Order {
    case asc(String)
    case desc(String)
    public var code:String{
        switch self {
        
        case let .asc(a):
            return "`\(a)` ASC"
        case let .desc(a):
            return "`\(a)` DESC"
        }
    }
}
public enum FetchKey{
    case count(String)
    case max(String)
    case min(String)
    case all
    
    public var keyString:String{
        switch self{
     
        case let .count(c):
            return "count(\(c))"
        case let .max(c):
            return "*,rowid,max(\(c))"
        case let .min(c):
            return "*,rowid,min(\(c))"
        case .all:
            return "*,rowid"
        }
    }
}
public class ObjectRequest<T:Object>{
    let sql:String
    public init(table:String,key:FetchKey = .all,condition:Condition? = nil ,page:Page? = nil,order:[Order] = []){
        self.sql = "select \(key.keyString) from `\(table)`" + ((condition?.conditionCode.count ?? 0) > 0 ? (" where " + condition!.conditionCode) : "") + (order.count > 0 ? " order by" + order.map({$0.code}).joined(separator: ",") : "") + (page == nil ? "" : " LIMIT \(page!.limit) OFFSET \(page!.offset)")
    }
    public func query(db:Database,valueMap:[String:DataType] = [:]) throws ->[T]{
        let rs = try db.query(sql: sql)
        for i in valueMap {
            i.value.bind(rs: rs, key: i.key)
        }
        var result:[T] = []
        while try rs.step() {
            let a = T()
            a.result(rs: rs)
            result.append(a)
        }
        return result
    }
}
