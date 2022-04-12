//
//  Pool.swift
//  Alpha
//
//  Created by wenyang on 2021/7/29.
//

import Foundation
import SQLite3

public class Pool{
    
    public enum Mode{
        case ACP
        case WAL
        case DELETE
    }
    /// 数据库地址
    /// - Returns: url
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
    /// 数据库备份地址
    /// - Returns: url
    static public func checkBackUpDir() throws->URL{
        let name = (Bundle.main.bundleIdentifier ?? "main" + ".Database") + ".back"
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    public let queue:DispatchQueue = DispatchQueue(label: "database", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    public var url:URL{
        self.wdb.url
    }
    private var read:List<DB> = List()
    private var wdb:DB
    private var semphone = DispatchSemaphore(value: 3)
    private var dbName:String
    private var thread:Thread?
    private var timer:Timer?
    /// 数据库创建
    /// - Parameter name: 数据库名
    public init(name:String) throws {
        
        self.wdb = try Pool.createDb(name: name)
        if try wdb.integrityCheck() == false{
            self.wdb.close()
            try? Pool.restore(name: name)
            self.wdb = try Pool.createDb(name: name)
        }
        self.dbName = name
        self.thread = Thread(block: {
            self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { t in
                self.backup()
            })
            RunLoop.current.run()
        })
        self.thread?.start()
        
    }
    /// 创建数据库
    /// - Parameter name: 数据名
    /// - Returns: DB
    public static func createDb(name:String,readOnly: Bool = false,writeLock: Bool = true) throws ->DB{
        let url = try Pool.checkDir().appendingPathComponent(name)
        let back = try Pool.checkBackUpDir().appendingPathComponent(name)
        
        if !FileManager.default.fileExists(atPath: url.path) && !FileManager.default.fileExists(atPath: back.path){
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }else if !FileManager.default.fileExists(atPath: url.path){
            try? Pool.restore(name: name)
        }
        
        return try DB(url: url,readOnly: readOnly,writeLock: writeLock)
    }
    /// 数据写入模式
    /// - Parameter mode: 模式
    public func loadMode(mode:Mode) throws {
        try self.queue.sync {
            switch mode {
            case .ACP:
                try self.wdb.synchronous(mode: .NORMAL)
                try self.wdb.setJournalMode(.WAL)
                try self.wdb.checkpoint(type: .passive, log: 100, total: 300)
            case .WAL:
                try self.wdb.synchronous(mode: .FULL)
                try self.wdb.setJournalMode(.WAL)
                try self.wdb.checkpoint(type: .passive, log: 100, total: 300)
            case .DELETE:
                try self.wdb.synchronous(mode: .FULL)
                try self.wdb.setJournalMode(.DELETE)
            }
        }
    }
    /// 数据库配置
    /// - Parameter callback: 操作
    public func config(callback:@escaping (DB) throws->Void){
        self.queue.sync(execute: DispatchWorkItem(flags: .barrier, block: {
            do{
                try callback(self.wdb)
            }catch{
                print(error)
            }
        }))
    }
    /// 只读
    /// - Parameter callback: 事务
    public func read(callback:@escaping (DB) throws->Void){
        self.queue.async {
            do {
                self.semphone.wait()
                defer{
                    
                    self.semphone.signal()
                }
                
                let db = try self.createReadOnly()
                try callback(db)
                self.read.append(element: db)
            }catch{
                print(error)
            }
        }
    }
    /// 只读
    /// - Parameter callback: 事务
    public func readSync(callback:@escaping (DB) throws->Void){
        self.queue.sync {
            do {
                self.semphone.wait()
                defer{
                    
                    self.semphone.signal()
                }
                
                let db = try self.createReadOnly()
                try callback(db)
                self.read.append(element: db)
            }catch{
                print(error)
            }
        }
    }
    /// 事务
    /// - Parameter callback: 事务
    public func transaction(callback:@escaping (DB) throws ->Bool){
        self.queue.async(execute: DispatchWorkItem(flags: .barrier, block: {
            let db = self.wdb
            do {
                try db.begin()
                if try callback(db){
                    try db.commit()
                }else{
                    try db.rollback()
                }
            }catch{
                print(error)
                try? db.rollback()
            }
        }))
    }
    /// 事务
    /// - Parameter callback: 事务
    public func transactionSync(callback:@escaping (DB) throws ->Bool){
        self.queue.sync(execute: DispatchWorkItem(flags: .barrier, block: {
            let db = self.wdb
            do {
                try db.begin()
                if try callback(db){
                    try db.commit()
                }else{
                    try db.rollback()
                }
            }catch{
                print(error)
                try? db.rollback()
            }
        }))
    }
    public func perform(callback:@escaping (DB) throws ->Void){
        self.queue.sync(execute: DispatchWorkItem(flags:.inheritQoS, block: {
            let db = self.wdb
            do {
                try callback(db)
            }catch{
                print(error)
            }
        }))
    }
    public func barrier(callback:@escaping (DB) throws ->Void){
        self.queue.sync(execute: DispatchWorkItem(flags:.barrier, block: {
            let db = self.wdb
            do {
                try callback(db)
            }catch{
                print(error)
            }
        }))
    }
    /// 读写
    /// - Parameter callback: 读写事物
    public func write(callback:@escaping (DB) throws ->Void){
        self.transaction(callback: { db in
            try callback(db)
            return true
        })
    }
    /// 读写
    /// - Parameter callback: 读写事物
    public func writeSync(callback:@escaping (DB) throws ->Void){
        self.transactionSync(callback: { db in
            try callback(db)
            return true
        })
    }
    ///  备份
    public func backup(){
        self.read { db in
            let u = try Pool.checkBackUpDir().appendingPathComponent(self.dbName)
            try BackupDatabase(url: u, source: db).backup()
        }
    }
    public static func restore(name:String) throws {
        let u = try Pool.checkBackUpDir().appendingPathComponent(name)
        let ur = try Pool.checkDir().appendingPathComponent(name)
        DispatchQueue.global().sync {
            do{
                #if DEBUG
                print("restore \(name)")
                #endif
                if FileManager.default.fileExists(atPath: ur.path){
                    try FileManager.default.removeItem(at: ur)
                }
                let source = try DB(url: u, readOnly: true, writeLock: true)
                try BackupDatabase(url: ur, source: source).backup()
            }catch{
                print("restore fail \(error)")
            }
        }
    }
    private func createReadOnly() throws ->DB{
        if let db = self.read.removeFirst(){
            return db
        }
        let db = try DB(url: self.url, readOnly: true, writeLock: true)
        return db
    }
    public var readDatabase:DB{
        try! self.createReadOnly()
    }
    deinit {
        self.wdb.close()
        for i in 0 ..< self.read.count {
            self.read[i]?.close()
        }
        self.thread?.cancel()
        self.timer?.invalidate()
    }
    public static let `default` = try! Pool(name: "AlphaDB")
}


