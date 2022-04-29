//
//  DataBase.swift
//  Alpha
//
//  Created by hao yin on 2022/4/12.
//

import Foundation
import SQLite3
import SQLite3.Ext

public class DataBase:Hashable{
    
    public let url:URL
    
    public private(set) var sqlite:OpaquePointer?
    
    public init(url:URL,readonly:Bool = false,writeLock:Bool = false) throws {
        self.url = url
        #if DEBUG
        print(url)
        #endif
        let r = readonly ? SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX  : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | (writeLock ? SQLITE_OPEN_FULLMUTEX: SQLITE_OPEN_NOMUTEX))
        if sqlite3_open_v2(url.path, &self.sqlite, r , nil) != noErr || self.sqlite == nil{
            throw NSError(domain: "数据库打开失败", code: 0)
        }
    }
    public convenience init(name:String,readonly:Bool = false,writeLock:Bool = false) throws {
        let url = try DataBase.checkDir().appendingPathComponent(name)
        try self.init(url: url, readonly: readonly, writeLock: writeLock)
    }
    public static func == (lhs: DataBase, rhs: DataBase) -> Bool {
        return lhs.url == rhs.url
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    public var foreignKeys:Bool{
        set{
            self.exec(sql: "PRAGMA foreign_keys = \(newValue ? 1 : 0)")
        }
        get{
            do {
                let rs = try self.prepare(sql: "PRAGMA foreign_keys")
                _ = try rs.step()
                let v = rs.columeInt(index: 0) > 0
                rs.close()
                return v
            }catch{
                return false
            }
            
        }
    }
    public func prepare(sql:String) throws->DataBase.ResultSet{
        var stmt:OpaquePointer?
        #if DEBUG
            print(sql)
        #endif
        if sqlite3_prepare(self.sqlite!, sql, Int32(sql.utf8.count), &stmt, nil) != SQLITE_OK{
            throw NSError(domain: DataBase.errormsg(pointer: self.sqlite), code: 1)
        }
        return DataBase.ResultSet(sqlite: self.sqlite!, stmt: stmt!)
    }
    
    public func exec(sql:String){
        #if DEBUG
            print(sql)
        #endif
        sqlite3_exec(self.sqlite, sql, nil, nil, nil)
    }
    public func close(){
        sqlite3_close(self.sqlite)
    }
    public class ResultSet{
        public let sqlite:OpaquePointer
        public let stmt:OpaquePointer
        public init(sqlite:OpaquePointer,stmt:OpaquePointer){
            self.sqlite = sqlite
            self.stmt = stmt
        }
        public func getParamIndexBy(name:String)->Int32{
            sqlite3_bind_parameter_index(self.stmt, name)
        }
        public func getParamNameBy(index:Int32)->String{
            String(cString: sqlite3_bind_parameter_name(self.stmt, index))
        }
        public var paramCount:Int32{
            sqlite3_bind_parameter_count(self.stmt)
        }
        public func bindNull(index:Int32) throws{
            if sqlite3_bind_null(self.stmt, index) != SQLITE_OK{
                throw NSError(domain: DataBase.errormsg(pointer: self.stmt), code: 4)
            }
        }
        public func bindZero(index:Int32,blobSize:Int64) throws{
            if sqlite3_bind_zeroblob64(self.stmt, index, sqlite3_uint64(blobSize)) != SQLITE_OK{
                throw NSError(domain: DataBase.errormsg(pointer: self.stmt), code: 4)
            }
        }
        public func bind<T>(index:Int32,value:T) throws{
            var flag:OSStatus = noErr
            if(value is Int32){
                flag = sqlite3_bind_int(self.stmt, index, value as! Int32)
            }else if(value is Int64){
                flag = sqlite3_bind_int64(self.stmt, index, value as! Int64)
            }else if (value is Int){
                if MemoryLayout<Int>.size == 8{
                    flag = sqlite3_bind_int64(self.stmt, index, Int64(value as! Int))
                }else{
                    flag = sqlite3_bind_int(self.stmt, index, Int32(value as! Int))
                }
            }else if(value is Double){
                flag = sqlite3_bind_double(self.stmt, index, value as! Double)
            }else if(value is Float){
                flag = sqlite3_bind_double(self.stmt, index, Double(value as! Float))
            }else if (value is String){
                let str = value as! String
                let c = str.cString(using: .utf8)
                let p = UnsafeMutablePointer<CChar>.allocate(capacity: str.utf8.count)
                memcpy(p, c, str.utf8.count)
                flag = sqlite3_bind_text(self.stmt, index, p, Int32(str.utf8.count)) { p in
                    p?.deallocate()
                }
            }else if (value is Data){
                let str = value as! Data
                let m:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: str.count)
                str.copyBytes(to: m, count: str.count)
                flag = sqlite3_bind_blob64(self.stmt, index, m, sqlite3_uint64(str.count), { p in p?.deallocate()})
            }else if (value is JSONModel){
                let str = (value as! JSONModel).jsonString
                let c = str.cString(using: .utf8)
                let p = UnsafeMutablePointer<CChar>.allocate(capacity: str.utf8.count)
                memcpy(p, c, str.utf8.count)
                flag = sqlite3_bind_text(self.stmt, index, p, Int32(str.utf8.count)) { p in
                    p?.deallocate()
                }
            }else if (value is Date){
                flag = sqlite3_bind_double(self.stmt, index, (value as! Date).timeIntervalSince1970)
            }else{
                flag = sqlite3_bind_value(self.stmt, index, value as? OpaquePointer)
            }
            if(flag != noErr){
                throw NSError(domain: DataBase.errormsg(pointer: self.sqlite), code: 4)
            }
        }
        public func bind(index:Int32,value:DBType,type:CollumnDecType) throws{
            if(value.isNull){
                try self.bindNull(index: index)
                return
            }
            switch(type){
            case .intDecType:
                try self.bind(index: index, value: value as! Int)
                break
            case .doubleDecType:
                try self.bind(index: index, value: value as! Double)
                break
            case .textDecType:
                try self.bind(index: index, value: value as! String)
                break
            case .dataDecType:
                try self.bind(index: index, value: value as! Data)
                break
            case .jsonDecType:
                try self.bind(index: index, value: value as! JSONModel)
                break
            case .dateDecType:
                try self.bind(index: index, value: value as! Date)
                break
            }
        }
        public func step() throws ->ResultSet.StepResult{
            let rc = sqlite3_step(self.stmt)
            if rc == SQLITE_ROW{
                return .hasColumn
            }
            if rc == SQLITE_DONE{
                return .end
            }
            throw NSError(domain: DataBase.errormsg(pointer: self.sqlite), code: 2)
        }
        public func columeName(index:Int32)->String{
            String(cString: sqlite3_column_name(self.stmt, index))
        }
        public func columeInt(index:Int32)->Int32{
            sqlite3_column_int(self.stmt, index)
        }
        public func columeInt64(index:Int32)->Int64{
            sqlite3_column_int64(self.stmt, index)
        }
        public func columeDouble(index:Int32)->Double{
            sqlite3_column_double(self.stmt, index)
        }
        public func columeFloat(index:Int32)->Float{
            Float(sqlite3_column_double(self.stmt, index))
        }
        public func columeString(index:Int32)->String{
            String(cString: sqlite3_column_text(self.stmt, index))
        }
        public func columeJSON(index:Int32)->JSONModel{
            let len = sqlite3_column_bytes(self.stmt, index)
            guard let byte = sqlite3_column_blob(self.stmt, index) else { return JSONModel(stringLiteral: "") }
            let data = Data(bytes: byte, count: Int(len))
            return JSONModel(jsonData: data)
        }
        public func columeDate(index:Int32)->Date{
            let time = sqlite3_column_double(self.stmt, index)
            return Date(timeIntervalSince1970: time)
        }
        public func colume(index:Int32)->DBType?{
            if self.columeDecType(index: index) == .jsonDecType{
                return self.columeJSON(index: index)
            }else if self.columeDecType(index: index) == .dateDecType{
                return self.columeDate(index: index)
            }else{
                switch (self.columeType(index: index)){
                case .nullCollumn:
                    return nil
                case .intCollumn:
                    return Int(self.columeInt(index: index))
                case .doubleCollumn:
                    return self.columeDouble(index: index)
                case .textCollumn:
                    return self.columeString(index: index)
                case .dataCollumn:
                    return self.columeData(index: index)
                }
            }
        }
        public func columeData(index:Int32)->Data{
            let len = sqlite3_column_bytes(self.stmt, index)
            guard let byte = sqlite3_column_blob(self.stmt, index) else { return Data() }
            return Data(bytes: byte, count: Int(len))
        }
        public func columeType(index:Int32)->CollumnType{
            if sqlite3_column_type(self.stmt, index) == SQLITE_INTEGER{
                return .intCollumn
            }else if sqlite3_column_type(self.stmt, index) == SQLITE_FLOAT{
                return .doubleCollumn
            }else if sqlite3_column_type(self.stmt, index) == SQLITE_TEXT{
                return .textCollumn
            }else if sqlite3_column_type(self.stmt, index) == SQLITE_BLOB{
                return .dataCollumn
            }else if sqlite3_column_type(self.stmt, index) == SQLITE_NULL{
                return .nullCollumn
            }
            return .nullCollumn
        }
        public func columeDecType(index:Int32)->CollumnDecType?{
            guard let r = sqlite3_column_decltype(self.stmt, index) else { return nil }
            return CollumnDecType(rawValue: String(cString: r))
        }
        public var columeCount:Int32{
            sqlite3_column_count(self.stmt)
        }
        public func close(){
            sqlite3_finalize(self.stmt)
        }
        public enum StepResult{
            case hasColumn
            case end
        }
    }
    static public func checkDir() throws->URL{
        let name = Bundle.main.bundleIdentifier ?? "main" + ".Database"
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    public static func errormsg(pointer:OpaquePointer?)->String{
        String(cString: sqlite3_errmsg(pointer))
    }
    public func deleteDatabaseFile(){
        do{
            try FileManager.default.removeItem(at: self.url)
        }catch{
            print(error)
        }
    }
}

public enum CollumnType{
    case nullCollumn
    case intCollumn
    case doubleCollumn
    case textCollumn
    case dataCollumn
}

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
public struct ForeignDeclareAction:Hashable{
    let action:String
    static public var CASCADE:ForeignDeclareAction = ForeignDeclareAction(action: "CASCADE")
    static public var NO_ACTION:ForeignDeclareAction = ForeignDeclareAction(action: "NO ACTION")
    static public var RESTRICT:ForeignDeclareAction = ForeignDeclareAction(action: "RESTRICT")
    static public var SET_NULL:ForeignDeclareAction = ForeignDeclareAction(action: "SET NULL")
    static public var SET_DEFAULT:ForeignDeclareAction = ForeignDeclareAction(action: "SET DEFAULT")
}

public struct ForeignDeclare{
    public var key:String
    public var refKey:String
    public var table:String?
    public var onDelete:ForeignDeclareAction?
    public var onUpdate:ForeignDeclareAction?
    public var code:String{
        
        let rf = table == nil ? refKey : "\(table!)(\(refKey))"
        
        return "FOREIGN KEY(\(key)) REFERENCES \(rf) \(onDelete != nil ? "onDelete \(onDelete!.action)":"") \(onUpdate != nil ? "onUpdate \(onUpdate!.action)":"")"
    }
}
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
    
    public static func buildBlock(_ name:String,_ components: CollumnDeclare...) -> TableDeclare {
        return TableDeclare(name: name,declare: components)
    }
}

public struct TableDeclare{
    public var name:String
    public var declare:[CollumnDeclare]
    public init(name:String,declare:[CollumnDeclare]){
        self.name = name
        self.declare = declare
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
        _ = try rs.step()
        rs.close()
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
}

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

public struct TableModel{
    public var name:String
    public var declare:[TableColumn]
    public var insertCode:String{
        "insert into \(self.name) (\(declare.map({$0.name}).joined(separator: ","))) values(\(declare.map({"@" + $0.name}).joined(separator: ",")))"
    }
    public var updateCode:String{
        "update `\(self.name)` set \(self.declare.map({"\($0.name)=@\($0.name)"}).joined(separator: ",")) " + primaryCondition
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
        for i in self.declare{
            let indx = rs.getParamIndexBy(name: "@"+i.name)
            try rs.bind(index: indx, value: i.origin, type: i.type)
        }
        _ = try rs.step()
        rs.close()
    }
    public func update(db:DataBase) throws {
        if self.hasPrimary{
            let rs = try db.prepare(sql: self.updateCode)
            for i in self.declare{
                let indx = rs.getParamIndexBy(name: "@"+i.name)
                try rs.bind(index: indx, value: i.origin, type: i.type)
            }
            try self.bindPrimaryConditionData(rs: rs)
            _ = try rs.step()
            rs.close()
        }else{
            throw NSError(domain: "model don't has primary key", code: 5)
        }
    }
    public func select(db:DataBase) throws{
        let map = self.declare.reduce(into: [:]) { partialResult, tc in
            partialResult[tc.name] = tc
        }
        let rs = try db.prepare(sql: self.selectCode)
        try self.bindPrimaryConditionData(rs: rs)
        while try rs.step() == .hasColumn{
            for i in 0 ..< rs.columeCount{
                let name = rs.columeName(index: i)
                if let v = rs.colume(index: i){
                    map[name]?.origin = v
                }
            }
        }
        for i in 0 ..< rs.columeCount{
            let name = rs.columeName(index: i)
            if let v = rs.colume(index: i){
                map[name]?.origin = v
            }
        }
        rs.close()
    }
    public func delete(db:DataBase) throws{
        let rs = try db.prepare(sql: "delete from \(self.name) \(self.primaryCondition)")
        try self.bindPrimaryConditionData(rs: rs)
        _ = try rs.step()
        rs.close()
    }
    
    public static func select(db:DataBase,keys:[String],table:String,condition:QueryCondition? = nil) throws -> [TableModel]{
        let select = "select \(keys.joined(separator: ",")) from \(table)" + (condition == nil ? "" : " where \(condition!.condition)")
        let rs = try db.prepare(sql: select)
        var models:[TableModel] = []
        while try rs.step() == .hasColumn {
            var a:[TableColumn] = []
            for i in 0 ..< rs.columeCount{
                if let c = rs.colume(index: i){
                    let tc = TableColumn(value: c, type: rs.columeDecType(index: i) ?? .textDecType, nullable: false, name: rs.columeName(index: i), primaryKey: false, unique: false,autoInc:false)
                    a.append(tc)
                }
            }
            models.append(TableModel(name: table, declare: a))
        }
        rs.close()
        return models
    }
    public func drop(db:DataBase){
        db.exec(sql: "drop table \(self.name)")
    }
    public static func delete(db:DataBase,table:String,condition:QueryCondition) throws{
        let sql = "delete from \(table) where \(condition.condition)"
        let rs = try db.prepare(sql: sql)
        _ = try rs.step()
        rs.close()
    }
}

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
        public init(key:String,table:DataBaseObject.Type? = nil){
            self.key = table == nil ? key : (table!.name + ".") + key
        }
        public init(jsonKey:String,keypath:String,table:DataBaseObject.Type? = nil){
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
