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
    
    public init(url:URL,readonly:Bool,writeLock:Bool) throws {
        self.url = url
        let r = readonly ? SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX  : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | (writeLock ? SQLITE_OPEN_FULLMUTEX: SQLITE_OPEN_NOMUTEX))
        if sqlite3_open_v2(url.path, &self.sqlite, r , nil) != noErr || self.sqlite == nil{
            throw NSError(domain: "数据库打开失败", code: 0)
        }
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
            if sqlite3_bind_null(self.stmt, index) == SQLITE_OK{
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 4)
            }
        }
        public func bindZero(index:Int32,blobSize:Int64) throws{
            if sqlite3_bind_zeroblob64(self.stmt, index, sqlite3_uint64(blobSize)) == SQLITE_OK{
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 4)
            }
        }
        public func bind<T>(index:Int32,value:T) throws{
            var flag:OSStatus = noErr
            if(value is Int32){
                flag = sqlite3_bind_int(self.sqlite, index, value as! Int32)
            }else if(value is Int64){
                flag = sqlite3_bind_int64(self.sqlite, index, value as! Int64)
            }else if (value is Int){
                if MemoryLayout<Int>.size == 8{
                    try self.bind(index: index, value: Int64(value as! Int))
                }else{
                    try self.bind(index: index, value: Int32(value as! Int))
                }
            }else if(value is Double){
                flag = sqlite3_bind_double(self.sqlite, index, value as! Double)
            }else if(value is Float){
                flag = sqlite3_bind_double(self.sqlite, index, Double(value as! Float))
            }else if (value is String){
                let str = value as! String
                flag = sqlite3_bind_text(self.sqlite, index, str, Int32(str.utf8.count)) { p in }
            }else if (value is Data){
                let str = value as! Data
                let m:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: str.count)
                str.copyBytes(to: m, count: str.count)
                flag = sqlite3_bind_blob64(self.stmt, index, m, sqlite3_uint64(str.count), { p in p?.deallocate()})
            }else{
                flag = sqlite3_bind_value(self.sqlite, index, value as? OpaquePointer)
            }
            if(flag != noErr){
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 4)
            }
        }
        public func step() throws{
            if noErr != sqlite3_step(self.stmt){
                throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite)), code: 2)
            }
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
        public func columeData(index:Int32)->Data{
            let len = sqlite3_column_bytes(self.stmt, index)
            guard let byte = sqlite3_column_blob(self.stmt, index) else { return Data() }
            return Data(bytes: byte, count: Int(len))
        }
        public func close(){
            sqlite3_finalize(self.stmt)
        }
    }
}
