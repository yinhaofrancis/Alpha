//
//  Database.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/22.
//

import Foundation
import SQLite3
import SQLite3.Ext
public struct WalMode:RawRepresentable{
    public init?(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public var rawValue: Int32
    
    public typealias RawValue = Int32
    

    public static var passive   = WalMode(rawValue: SQLITE_CHECKPOINT_PASSIVE)!
    public static var full      = WalMode(rawValue: SQLITE_CHECKPOINT_FULL)!
    public static var restart   = WalMode(rawValue: SQLITE_CHECKPOINT_RESTART)!
    public static var truncate  = WalMode(rawValue: SQLITE_CHECKPOINT_TRUNCATE)!
    
}
public struct ForeignKeyAction:Hashable{
    let action:String
    static public var CASCADE:ForeignKeyAction = ForeignKeyAction(action: "CASCADE")
    static public var NO_ACTION:ForeignKeyAction = ForeignKeyAction(action: "NO ACTION")
    static public var RESTRICT:ForeignKeyAction = ForeignKeyAction(action: "RESTRICT")
    static public var SET_NULL:ForeignKeyAction = ForeignKeyAction(action: "SET NULL")
    static public var SET_DEFAULT:ForeignKeyAction = ForeignKeyAction(action: "SET DEFAULT")
}

public enum JournalMode:String{
    case DELETE
    case TRUNCATE
    case PERSIST
    case MEMORY
    case WAL
    case OFF
}
public enum synchronousMode:String{
    case EXTRA
    case FULL
    case NORMAL
    case OFF
}

public class Database:Hashable{
    public static func == (lhs: Database, rhs: Database) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    private var uuid = UUID().uuidString
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    public let url:URL
    public var sqlite:OpaquePointer?
    public init(url:URL,readOnly:Bool = false) throws{
        self.url = url
        let r = readOnly ? SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX  : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX)
        sqlite3_open_v2(url.path, &self.sqlite, r , nil)
        if(self.sqlite == nil){
            throw NSError(domain: "create sqlite3 fail", code: 0, userInfo: ["url":url])
        }
        self.hook()
    }
    deinit {
        sqlite3_close(self.sqlite)
    }
    public class ResultSet{
        
        public enum DBDataType{
            case Integer
            case Float
            case Text
            case Blob
            case Null
        }
        public enum DBModelType{
            case int32
            case int64
            case string
            case double
            case data
        }
        
        private var stmt:OpaquePointer
        private var nextSql:String?
        private unowned var db:Database
        public init(stmt:OpaquePointer,db:Database,nextSql:String? = nil) {
            self.stmt = stmt
            self.db = db
            self.nextSql = nextSql
        }
        @discardableResult
        public func step() throws ->Bool{
            let rc = sqlite3_step(self.stmt)
            if rc == SQLITE_ROW{
                return true
            }
            if rc == SQLITE_DONE{
                return false
            }
            
            throw NSError(domain: Database.errormsg(pointer: self.db.sqlite!), code: Int(rc), userInfo: ["sql":String(cString: sqlite3_sql(self.stmt))])
        }
        public func columnName(index:Int)->String{
            String(cString: sqlite3_column_name(self.stmt, Int32(index)))
        }
        public func type(index:Int32)->DBDataType{
            let a = sqlite3_column_type(self.stmt, index)
            switch a {
            case SQLITE_INTEGER:
                return .Integer
            case SQLITE_FLOAT:
                return .Float
            case SQLITE_TEXT:
                return .Text
            case SQLITE_BLOB:
                return .Blob
            default:
                return .Null
            }
        }
        public func close(){
            sqlite3_finalize(self.stmt)
        }
        public var columnCount:Int{
            Int(sqlite3_column_count(self.stmt))
        }
        public func index(paramName:String)->Int32{
            let index = sqlite3_bind_parameter_index(self.stmt, paramName)
            return index
        }
        public func bind<T>(index:Int32)->Bind<T>{
            Bind<T>.init(stmt: self.stmt, index: index)
        }
        public func bind<T>(name:String)->Bind<T>?{
            let index = self.index(paramName: name)
            if(index == 0){
                return nil
            }
            return Bind<T>.init(stmt: self.stmt, index: index)
        }
        public func bindNull(index:Int32){
            sqlite3_bind_null(self.stmt, index)
        }
        public func bindNull(name:String){
            let index = self.index(paramName: name)
            sqlite3_bind_null(self.stmt, index)
        }
        public func column<T>(index:Int32,type:T.Type)->Column<T>{
            Column.init(stmt: self.stmt, index: index)
        }        
        public var paramCount:Int32{
            sqlite3_bind_parameter_count(self.stmt)
        }
        public struct Bind<T>{
            public var stmt:OpaquePointer
            public var index:Int32
            public func bind(value:T) where T == Int32{
                sqlite3_bind_int(self.stmt, index, value)
            }
            public func bind(value:T) where T == Int{
                if MemoryLayout.size(ofValue: value) == 4{
                    sqlite3_bind_int(self.stmt, index, Int32(value))
                }else{
                    sqlite3_bind_int64(self.stmt, index, Int64(value))
                }
            }
            public func bind(value:T) where T == Int64{
                sqlite3_bind_int64(self.stmt, index, value)
            }
            public func bind(value:T) where T == Double{
                sqlite3_bind_double(self.stmt, index, value)
            }
            public func bind(value:T) where T == Float{
                sqlite3_bind_double(self.stmt, index, Double(value))
            }
            public func bind(value:T) where T == String{
                guard let c = value.cString(using: .utf8) else {
                    sqlite3_bind_null(self.stmt, index)
                    return
                }
                let p = UnsafeMutablePointer<CChar>.allocate(capacity: value.utf8.count)
                memcpy(p, c, value.utf8.count)
                sqlite3_bind_text(self.stmt, index, p, Int32(value.utf8.count)) { p in
                    p?.deallocate()
                }
            }
            public func bind(value:T) where T == Data{
                let pointer = sqlite3_malloc(Int32(value.count))
                let buffer = UnsafeMutableRawBufferPointer(start: pointer, count: value.count)
                value.copyBytes(to: buffer, count: value.count)
                sqlite3_bind_blob64(self.stmt, index, pointer, sqlite3_uint64(value.count)) { po in
                    sqlite3_free(po)
                }
            }
            public var name:String{
                String(cString: sqlite3_bind_parameter_name(self.stmt, self.index))
            }
        }
        public struct Column<T>{
            public var stmt:OpaquePointer
            public var index:Int32
            public func value()->T where T == Int32{
                sqlite3_column_int(self.stmt, index)
            }
            public func value()->T where T == Int64{
                sqlite3_column_int64(self.stmt, index)
            }
            public func value()->T where T == String{
                let len = sqlite3_column_bytes(self.stmt, index)
                guard let byte = sqlite3_column_text(self.stmt, index) else { return "" }
                return String(data: Data(bytes: byte, count: Int(len)), encoding: .utf8) ?? ""
            }
            public func value()->T where T == Double{
                sqlite3_column_double(self.stmt,index)
            }
            public func value()->T where T == Float{
                Float(sqlite3_column_double(self.stmt,index))
            }
            public func value()->T where T == Int{
                if MemoryLayout<T>.size == 4{
                    return Int(sqlite3_column_int(self.stmt, index))
                }else{
                    return Int(sqlite3_column_int64(self.stmt, index))
                }
            }
            public func value()->T where T == Data{
                let len = sqlite3_column_bytes(self.stmt, index)
                guard let byte = sqlite3_column_blob(self.stmt, index) else { return Data() }
                return Data(bytes: byte, count: Int(len))
            }
            public var tableName:String{
                String(cString: sqlite3_column_table_name(self.stmt, index))
            }
            public var databaseName:String{
                String(cString: sqlite3_column_database_name(self.stmt, index))
            }
            public var name:String{
                String(cString: sqlite3_column_name(self.stmt, index))
            }
            public var type:DBDataType{
                let a = sqlite3_column_type(self.stmt, index)
                switch a {
                case SQLITE_INTEGER:
                    return .Integer
                case SQLITE_FLOAT:
                    return .Float
                case SQLITE_TEXT:
                    return .Text
                case SQLITE_BLOB:
                    return .Blob
                default:
                    return .Null
                }
            }
        }
    }
}

public struct TableInfo{
    public let cid:Int
    public let name:String
    public let type:String
    public let notnull:Int
    public let dlft_value:String
    public let pk:Int
}
public struct DataMasterInfo{
    public let type:String
    public let name:String
    public let tblName:String
    public let rootPage:Int
    public let sql:String
}

public struct TableForeignKeyInfo{
    public let id:Int
    public let seq:Int
    public let table:String
    public let from:String
    public let to:String
    public let onUpdate:ForeignKeyAction
    public let onDelete:ForeignKeyAction
    public let match:String
}

extension Database{
    public func exec(sql:String) throws {
        #if DEBUG
        print("SQL:"+sql)
        #endif
        var error:UnsafeMutablePointer<CChar>?
        sqlite3_exec(self.sqlite, sql, { arg, len, v,col in
            #if DEBUG
            print("<<<<<<<<<<<<")
            for i in 0 ..< len{
                let vstr = v?[Int(i)] == nil ? "NULL" : String(cString: v![Int(i)]!)
                let cStr = col?[Int(i)] == nil ? "NULL" : String(cString: col![Int(i)]!)
                print("\(cStr):\(vstr)")
            }
            print(">>>>>>>>>>>>>")
            #endif
            return 0
        }, nil, &error)
        if let e = error{
            let data = Data(bytes: e, count: strlen(e))
            sqlite3_free(error)
            throw NSError(domain: String(data: data, encoding: .utf8) ?? "unknow error", code: 0, userInfo: ["sql":sql])
        }
    }
    public func query(sql:String) throws ->ResultSet{
        #if DEBUG
        print("SQL:"+sql)
        #endif
        var stmt:OpaquePointer?
        let nextSql:UnsafeMutablePointer<UnsafePointer<CChar>?> = .allocate(capacity: 1)
        let rc = sqlite3_prepare(self.sqlite, sql, Int32(sql.utf8.count), &stmt, nextSql)
        if rc != SQLITE_OK{
            throw NSError(domain:  Database.errormsg(pointer: self.sqlite!), code: Int(rc), userInfo: ["sql":sql])
        }
        guard let s = stmt else { throw NSError(domain: Database.errormsg(pointer: self.sqlite!), code: 0, userInfo: ["sql":sql])}
        if let cs = nextSql.pointee{
            let nsql = String(cString: cs)
            nextSql.deallocate()
            return ResultSet(stmt: s, db: self,nextSql: nsql)
        }else{
            return ResultSet(stmt: s, db: self)
        }
    }
    public func addColumn(name:String,columeName:String, typedef:String ,notnull:Bool = false ,defaultValue:String = "") throws {
        let sql = "ALTER TABLE \(name) ADD COLUMN \(columeName) \(typedef) \(notnull ? "default `\(defaultValue)`" : "" )"
        try self.exec(sql: sql)
    }
    public func addScalarFunction(function:ScalarFunction){
        sqlite3_create_function(self.sqlite!, function.name, function.nArg, SQLITE_UTF8, Unmanaged.passUnretained(function).toOpaque(), { ctx, i, ret in
            let call = Unmanaged<ScalarFunction>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
            call.ctx = ctx
            call.call(call,i,ret?.pointee)
        }, nil, nil)
    }
    public func checkpoint(type:WalMode,log:Int32,total:Int32) throws {
        let l = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let t = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        l.pointee = log
        t.pointee = total
        let code = sqlite3_wal_checkpoint_v2(self.sqlite, nil, type.rawValue, l, t)
        l.deallocate()
        t.deallocate()
        if SQLITE_OK != code{
            throw NSError(domain: Self.errormsg(pointer: self.sqlite), code: Int(code), userInfo: nil)
        }
    }
    public func rollback() throws{
        try self.exec(sql: "ROLLBACK;")
    }
    public func commit() throws {
        try self.exec(sql: "COMMIT;")
    }
    public func begin() throws {
        try self.exec(sql: "BEGIN;")
    }
    public static func errormsg(pointer:OpaquePointer?)->String{
        String(cString: sqlite3_errmsg(pointer))
    }
    public func autoCheckpoint(frame:Int32 = 100) throws{
        let code = sqlite3_wal_autocheckpoint(self.sqlite, frame)
        if SQLITE_OK != code{
            throw NSError(domain: Self.errormsg(pointer: self.sqlite), code: Int(code), userInfo: nil)
        }
    }
    public func setJournalMode(_ model:JournalMode) throws {
        try self.exec(sql: "PRAGMA journal_mode = \(model)")
    }
    private func hook(){
        sqlite3_wal_hook(self.sqlite, { s, sql, c, co in
            guard let str = c else { return 0 }
            print("-------------")
            print("DO WAL :" + String(cString: str))
            print("-------------")
            return 0
        }, Unmanaged.passUnretained(self).toOpaque())
        
        sqlite3_commit_hook(self.sqlite, { s in
            print("-------------")
            print("DO COMMIT :")
            print("-------------")
            return 0
        }, Unmanaged.passUnretained(self).toOpaque())
        
        sqlite3_rollback_hook(self.sqlite, { s in
            print("-------------")
            print("DO ROLLBACK")
            print("-------------")
        }, Unmanaged.passUnretained(self).toOpaque())
    }
    public func synchronous(mode:synchronousMode) throws {
        try self.exec(sql: "PRAGMA synchronous = " + mode.rawValue)
    }
    public func setVersion(version:Int) throws {
        try self.exec(sql: "PRAGMA user_version=\(version)")
    }
    public var version:Int{
        do{
            let rs = try self.query(sql: "PRAGMA user_version")
            defer {
                rs.close()
            }
            try rs.step()
            let v =  rs.column(index: 0, type: Int.self).value()
            return v
        }catch{
            return 0
        }
    }
    public func dataMaster(type:String,name:String? = nil) throws->[DataMasterInfo]{
        let re = try self.query(sql: "select * from sqlite_master where type=? \(name != nil ? "and name=?" : "") ")
        re.bind(index: 1).bind(value: type)
        if let n = name {
            re.bind(index: 2).bind(value: n)
        }
        var array:[DataMasterInfo] = []
        while try re.step(){
            let dmi = DataMasterInfo(type: re.column(index: 0, type: String.self).value(),
                           name: re.column(index: 1, type: String.self).value(),
                           tblName: re.column(index: 2, type: String.self).value(),
                           rootPage: re.column(index: 3, type: Int.self).value(),
                           sql: re.column(index: 4, type: String.self).value())
            array.append(dmi)
        }
        re.close()
        return array
    }
    public func tableInfo(name:String) throws ->[String:TableInfo]{
        let r = try self.query(sql: "PRAGMA table_info(\(name))")
        var map:[String:TableInfo] = [:]
        while try r.step() {
            
            let tav = TableInfo(cid: r.column(index: 0, type: Int.self).value(),
                                name: r.column(index: 1, type: String.self).value(),
                                type: r.column(index: 2, type: String.self).value(),
                                notnull: r.column(index: 3, type: Int.self).value(),
                                dlft_value: r.column(index: 4, type: String.self).value(),
                                pk: r.column(index: 5, type: Int.self).value())
            map[tav.name] = tav
            
        }
        r.close()
        return map
    }
    public func tableExists(name:String) throws ->Bool{
       return  try self.dataMaster(type: "table", name: name).count > 0
    }
    public func tableForeignKeyInfo(name:String) throws ->[String:TableForeignKeyInfo]{
        let r = try self.query(sql: "PRAGMA foreign_key_list(\(name));")
        var map:[String:TableForeignKeyInfo] = [:]
        while try r.step() {
            
            let tav = TableForeignKeyInfo(id: r.column(index: 0, type: Int.self).value(),
                                          seq: r.column(index: 1, type: Int.self).value(),
                                          table:r.column(index: 2, type: String.self).value(),
                                          from:r.column(index: 3, type: String.self).value(),
                                          to:r.column(index: 4, type: String.self).value(),
                                          onUpdate: ForeignKeyAction(action: r.column(index: 5, type: String.self).value()),
                                          onDelete: ForeignKeyAction(action: r.column(index: 6, type: String.self).value()),
                                          match: r.column(index: 7, type: String.self).value())
            map[tav.from] = tav
        }
        r.close()
        return map
    }
    public func integrityCheck(table:String) throws ->Bool{
        let r = try self.query(sql: "PRAGMA INTEGRITY_CHECK(\(table))")
        if try r.step(){
            let v = r.column(index: 0, type: String.self).value() == "ok"
            r.close()
            return v
        }
        r.close()
        return false
    }
    public var foreignKey:Bool{
        get{
            do{
                let r = try self.query(sql: "PRAGMA foreign_keys")
                try r.step()
                let a = r.column(index: 0, type: Int32.self).value() > 0
                r.close()
                return a
            }catch{
                return false
            }
            
        }
        set{
            try? self.exec(sql: "PRAGMA foreign_keys = \(newValue ? "ON" : "OFF")")
        }
    }
    public func close(){
        sqlite3_close(self.sqlite)
    }
}
