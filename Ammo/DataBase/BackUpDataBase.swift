//
//  BackUpDataBase.swift
//  Ammo
//
//  Created by hao yin on 2022/4/21.
//

import Foundation
import SQLite3

public class BackUpDataBase{
    fileprivate var backupPointer:DataBase
    private var origin:DataBase
    private var bkup:OpaquePointer?
    public init(url:URL,database:DataBase) throws{
        self.backupPointer = try DataBase(url: url)
        self.origin = database
        self.bkup = sqlite3_backup_init(self.backupPointer.sqlite!, "main", database.sqlite, "main")
        if(self.bkup == nil){
            throw NSError(domain: "create back fail", code: 0)
        }
    }
    public convenience init(name:String,database:DataBase) throws{
        let u = try BackUpDataBase.checkDir().appendingPathComponent(name)
        try self.init(url: u, database: database)
    }
    public func backup() throws {
        guard let bk = self.bkup else { throw NSError(domain: "backup fail", code: 0) }
        while true{
            let r = sqlite3_backup_step(bk, -1)
            if r == SQLITE_OK || r == SQLITE_BUSY || r == SQLITE_LOCKED{
                continue
            }
            if(r == SQLITE_DONE){
                try self.finish()
                break
            }
            throw NSError(domain: "backup fail end", code: 0)
        }
    }
    private func finish() throws{
        guard let bk = self.bkup else {throw NSError(domain: "backup fail", code: 0) }
        sqlite3_backup_finish(bk)
    }
    public var remaining:Int{
        guard let bk = self.bkup else { return 0 }
        return Int(sqlite3_backup_remaining(bk))
    }
    deinit{
        self.backupPointer.close()
    }
    /// 数据页数
    public var pageCount:Int {
        guard let bk = self.bkup else { return 0 }
        return Int(sqlite3_backup_pagecount(bk))
    }
    static public func checkDir() throws->URL{
        let name = Bundle.main.bundleIdentifier ?? "main" + ".backup"
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name + ".backup")
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
}
public class RestoreDataBase{
    private var bkup:OpaquePointer?
    private var restoreDb:DataBase
    private var backupDb:DataBase
    public init(url:URL,backup:URL) throws{
        self.restoreDb = try DataBase(url: url)
        self.backupDb = try DataBase(url: backup)
        self.bkup = sqlite3_backup_init(self.restoreDb.sqlite, "main", self.backupDb.sqlite, "main")
    }
    public convenience init(name:String,backup:String) throws{
        let u = try DataBase.checkDir().appendingPathComponent(name)
        let ub = try BackUpDataBase.checkDir().appendingPathComponent(backup)
        try self.init(url: u, backup: ub)
    }
    public func restore() throws{
        while true{
            let r = sqlite3_backup_step(self.bkup, -1)
            if r == SQLITE_OK || r == SQLITE_BUSY || r == SQLITE_LOCKED{
                continue
            }else if(r == SQLITE_DONE){
                sqlite3_backup_finish(self.bkup)
                break
            }else{
                sqlite3_backup_finish(self.bkup)
                throw NSError(domain: DataBase.errormsg(pointer: self.bkup), code: 0)
            }
        }
    }
    deinit{
        self.restoreDb.close()
        self.backupDb.close()
    }
}
