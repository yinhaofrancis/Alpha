//
//  Database.swift
//  Alpha
//
//  Created by hao yin on 2022/4/12.
//

import Foundation
import SQLite3
import SQLite3.Ext

public struct Database:Hashable{
    
    public let url:URL
    
    public private(set) var sqlite:OpaquePointer?
    
    public init(url:URL,readonly:Bool = false,mutex:Bool = false) throws {
        self.url = url
        #if DEBUG
        print(url)
        #endif
        let r = readonly ? SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX  : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | (mutex ? SQLITE_OPEN_FULLMUTEX: SQLITE_OPEN_NOMUTEX))
        if sqlite3_open_v2(url.path, &self.sqlite, r , nil) != noErr || self.sqlite == nil{
            throw NSError(domain: "数据库打开失败", code: 0)
        }
    }
    public init(name:String,readonly:Bool = false,mutex:Bool = false) throws {
        let url = try Database.checkDir().appendingPathComponent(name)
        try self.init(url: url, readonly: readonly, mutex: mutex)
    }
    public static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.url == rhs.url
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    public func tableExist(name:String) throws->Bool{
        let rs = try self.prepare(sql: "PRAGMA table_info(\(name))")
        defer{
            rs.close()
        }
        if try rs.step() == .hasColumn{
            return true
        }else{
            return false
        }
    }
    public var DatabaseVersion:Int{
        get{
            do {
                let rs = try self.prepare(sql: "PRAGMA user_version")
                defer{
                    rs.close()
                }
                _ = try rs.step()
                let v = rs.columeInt(index: 0)
                
                return v
            }catch{
                return 0
            }
        }
        set{
            self.exec(sql: "PRAGMA user_version = \(newValue)")
        }
    }
    public var foreignKeys:Bool{
        set{
            self.exec(sql: "PRAGMA foreign_keys = \(newValue ? 1 : 0)")
        }
        get{
            do {
                let rs = try self.prepare(sql: "PRAGMA foreign_keys")
                defer{
                    rs.close()
                }
                _ = try rs.step()
                let v = rs.columeInt(index: 0) > 0
                
                return v
            }catch{
                return false
            }
            
        }
    }
    public func begin(){
        self.exec(sql: "begin")
    }
    public func commit(){
        self.exec(sql: "commit")
    }
    public func rollback(){
        self.exec(sql: "rollback")
    }
    public func prepare(sql:String) throws->Database.ResultSet{
        var stmt:OpaquePointer?
        #if DEBUG
            print(sql)
        #endif
        if sqlite3_prepare(self.sqlite!, sql, Int32(sql.utf8.count), &stmt, nil) != SQLITE_OK{
            throw NSError(domain: Database.errormsg(pointer: self.sqlite), code: 1)
        }
        return Database.ResultSet(sqlite: self.sqlite!, stmt: stmt!)
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
    public struct ResultSet{
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
                throw NSError(domain: Database.errormsg(pointer: self.stmt), code: 4)
            }
        }
        public func bindZero(index:Int32,blobSize:Int64) throws{
            if sqlite3_bind_zeroblob64(self.stmt, index, sqlite3_uint64(blobSize)) != SQLITE_OK{
                throw NSError(domain: Database.errormsg(pointer: self.stmt), code: 4)
            }
        }
        public func bind<T>(name:String,value:T) throws{
            let i = self.getParamIndexBy(name: name)
            try self.bind(index: i, value: value)
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
            }else if (value is Date){
                flag = sqlite3_bind_double(self.stmt, index, (value as! Date).timeIntervalSince1970)
            }else{
                flag = sqlite3_bind_value(self.stmt, index, value as? OpaquePointer)
            }
            if(flag != noErr){
                throw NSError(domain: Database.errormsg(pointer: self.sqlite), code: 4)
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
            throw NSError(domain: Database.errormsg(pointer: self.sqlite), code: 2)
        }
        public func columeName(index:Int32)->String{
            String(cString: sqlite3_column_name(self.stmt, index))
        }
        public func columeInt(index:Int32)->Int{
            if MemoryLayout<Int>.size == 4{
                return Int(sqlite3_column_int(self.stmt, index))
            }else{
                return Int(sqlite3_column_int64(self.stmt, index))
            }
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
 
        public func columeDate(index:Int32)->Date{
            let time = sqlite3_column_double(self.stmt, index)
            return Date(timeIntervalSince1970: time)
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


