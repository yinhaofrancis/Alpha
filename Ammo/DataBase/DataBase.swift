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
    
    
    private var sqlite:OpaquePointer?
    
    public init(url:URL,readonly:Bool = false,writeLock:Bool = false) throws {
        self.url = url
        let r = readonly ? SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX  : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | (writeLock ? SQLITE_OPEN_FULLMUTEX: SQLITE_OPEN_NOMUTEX))
        if sqlite3_open_v2(url.path, &self.sqlite, r , nil) != noErr || self.sqlite == nil{
            throw NSError(domain: "数据库打开失败", code: 0)
        }
    }
    public convenience init(name:String,readonly:Bool,writeLock:Bool) throws {
        let url = try DataBase.checkDir().appendingPathComponent(name)
        try self.init(url: url, readonly: readonly, writeLock: writeLock)
    }
    public static func == (lhs: DataBase, rhs: DataBase) -> Bool {
        return lhs.url == rhs.url
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    public func prepare(sql:String) throws->DataBase.ResultSet{
        var stmt:OpaquePointer?
        if sqlite3_prepare(self.sqlite!, sql, Int32(sql.utf8.count), &stmt, nil) != SQLITE_OK{
            throw NSError(domain: String(cString: sqlite3_errmsg(sqlite!)), code: 1)
        }
        return DataBase.ResultSet(sqlite: self.sqlite!, stmt: stmt!)
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
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 4)
            }
        }
        public func bindZero(index:Int32,blobSize:Int64) throws{
            if sqlite3_bind_zeroblob64(self.stmt, index, sqlite3_uint64(blobSize)) != SQLITE_OK{
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 4)
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
                flag = sqlite3_bind_text(self.stmt, index, str, Int32(str.utf8.count)) { p in }
            }else if (value is Data){
                let str = value as! Data
                let m:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: str.count)
                str.copyBytes(to: m, count: str.count)
                flag = sqlite3_bind_blob64(self.stmt, index, m, sqlite3_uint64(str.count), { p in p?.deallocate()})
            }else{
                flag = sqlite3_bind_value(self.stmt, index, value as? OpaquePointer)
            }
            if(flag != noErr){
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 4)
            }
        }
        public func bind(index:Int32,value:DBType,type:CollumnType) throws{
            if(value.isNull){
                try self.bindNull(index: index)
                return
            }
            switch(type){
            case .nullCollumn:
                try self.bindNull(index: index)
                break
            case .intCollumn:
                try self.bind(index: index, value: value as! Int)
                break
            case .doubleCollumn:
                try self.bind(index: index, value: value as! Double)
                break
            case .textCollumn:
                try self.bind(index: index, value: value as! String)
                break
            case .dataCollumn:
                try self.bind(index: index, value: value as! Data)
                break
            }
        }
        public func step() throws ->ResultSet.StepResult{
            let rc = sqlite3_step(self.stmt)
            if rc == SQLITE_ROW{
                return .hasMore
            }
            if rc == SQLITE_DONE{
                return .end
            }
            throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 2)
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
        public func colume(index:Int32)->DBType?{
            switch(self.columeType(index: index)){
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
            case hasMore
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
        }
    }
}

public class CollumnDeclare:NSObject{
    public var type:CollumnDecType
    public var nullable:Bool
    public var name:String
    public var primaryKey:Bool
    public var unique:Bool
    public init(type:CollumnDecType,nullable:Bool, name:String, primaryKey:Bool,unique:Bool){
        self.type = type
        self.nullable = nullable
        self.name = name
        self.primaryKey = primaryKey
        self.unique = unique
    }
    public static func primaryCollumn(name:String,type:CollumnDecType)->CollumnDeclare{
        CollumnDeclare(type: type, nullable: false, name: name, primaryKey: true, unique: false)
    }
    public static func normalCollumn(name:String,type:CollumnDecType)->CollumnDeclare{
        CollumnDeclare(type: type, nullable: true, name: name, primaryKey: false, unique: false)
    }
    public var code:String{
        return "\(name) \(type.rawValue) \(unique ? "unique":"") \(nullable ? "" : "NOT NULL")"
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
    public var code:String{
        let pk = self.declare.filter({$0.primaryKey})
        if(pk.count > 0){
            
            let pkv = ",PRIMARY KEY(\(pk.map({"\"\($0.name)\""}).joined(separator: ",")))"
            return "create table if not exists \(name) (\(self.declare.map({$0.code}).joined(separator: ",")) \(pkv))"
        }else{
            return "create table if not exists \(name) (\(self.declare.map({$0.code}).joined(separator: ",")))"
        }
    }
    public func create(db:DataBase) throws {
        let rs = try db.prepare(sql: self.code)
        _ = try rs.step()
        rs.close()
    }
}

public class TableColumn:CollumnDeclare{
    public var origin:DBType
    public init(value:DBType,type:CollumnDecType,nullable:Bool, name:String, primaryKey:Bool,unique:Bool){
        self.origin = value
        super.init(type: type, nullable: nullable, name: name, primaryKey: primaryKey, unique: unique)
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
        return "where " + self.declare.filter({$0.primaryKey}).map({"\($0.name)=@p\($0.name)"}).joined(separator: "and")
    }
    public var selectCode:String{
        "select * from \(self.name) " + self.primaryCondition
    }
    public var hasPrimary:Bool{
        return self.declare.filter({$0.primaryKey}).count > 0
    }
    public func bindPrimaryConditionData(rs:DataBase.ResultSet) throws{
        for i in  self.declare.filter({$0.primaryKey}){
            let index = rs.getParamIndexBy(name: "@p"+i.name)
            try rs.bind(index: index, value: i.origin, type: i.type.collumnType)
        }
    }
    public func insert(db:DataBase) throws {
        let rs = try db.prepare(sql: self.insertCode)
        for i in self.declare{
            let indx = rs.getParamIndexBy(name: "@"+i.name)
            print(i.origin)
            try rs.bind(index: indx, value: i.origin, type: i.type.collumnType)
        }
        _ = try rs.step()
        rs.close()
    }
    public func update(db:DataBase) throws {
        if self.hasPrimary{
            let rs = try db.prepare(sql: self.updateCode)
            for i in self.declare{
                let indx = rs.getParamIndexBy(name: "@"+i.name)
                print(i.origin)
                try rs.bind(index: indx, value: i.origin, type: i.type.collumnType)
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
        while try rs.step() == .hasMore{
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
}

public protocol QueryColumn{
    var defineCode:String { get }
    var relateTable:String { get }
}

public class QueryModel{
    var columes:[QueryColumn]
    public init(columes:[QueryColumn]){
        self.columes = columes
    }
    
}
