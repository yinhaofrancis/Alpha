//
//  DataBaseWorkFlow.swift
//  Ammo
//
//  Created by hao yin on 2022/4/26.
//

import Foundation

public class DataBaseWorkFlow{
    fileprivate var writeQueue:DispatchQueue = DispatchQueue(label: "DataBaseWorkFlow", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    fileprivate var wdb:DataBase
    private var semaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
    public init(name:String) throws {
        self.wdb = try DataBase(name: name, readonly: false, writeLock: true)
    }
    public init(config:DataBaseConfiguration) throws{
        self.wdb = try config.configure()
    }
    public func workflow(_ callback:@escaping (DataBase) throws ->Void){
        self.writeQueue.async(execute: DispatchWorkItem(qos: .userInitiated, flags: .barrier, block: {
            do{
                self.wdb.begin()
                try callback(self.wdb)
                self.wdb.commit()
            }catch{
                self.wdb.rollback()
            }
        }))
    }
    public func query(_ callback:@escaping (DataBase) throws ->Void) throws{
        let db = try DataBase(url: self.wdb.url, readonly: true, writeLock: false)
        self.writeQueue.async {
            do{
                try callback(db)
            }catch{
                print(error)
            }
            db.close()
        }
    }
    deinit{
        self.wdb.close()
    }
}

@propertyWrapper
public struct DBWorkFlow{
    private static var workFlow:[String:DataBaseWorkFlow] = [:]
    
    private var semaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
                                 
    public var name:String
    
    public var wrappedValue:DataBaseWorkFlow{
        defer{
            semaphore.signal()
        }
        semaphore.wait()
        guard let a = DBWorkFlow.workFlow[name] else {
            DBWorkFlow.workFlow[name] = try! DataBaseWorkFlow(name: self.name)
            return DBWorkFlow.workFlow[name]!
        }
        return a
    }
    
    public init(name:String){
        self.name = name
    }
    public init(configure:DataBaseConfiguration){
        self.name = configure.name
        guard DBWorkFlow.workFlow[name]  != nil else {
            DBWorkFlow.workFlow[name] = try! DataBaseWorkFlow(config: configure)
            return
        }
    }
}

@resultBuilder
public struct DBUpdate{
    public static func buildBlock(_ components: DataBaseUpdateCallback...) -> DataBaseUpdate {
        DataBaseUpdate(callbacks: components)
    }
    public static func buildBlock(_ components:DataBaseUpdateCallback.CallbackBlock...) -> DataBaseUpdate {
        
        var a:[DataBaseUpdateCallback] = []
        for i in 1 ... components.count{
            a.append(DataBaseUpdateCallback(version: Int32(i), callback: components[i - 1]))
        }
        
        return DataBaseUpdate(callbacks: a)
    }
}
public struct DataBaseUpdateCallback{
    public typealias CallbackBlock = (Int32,DataBase) throws ->Void
    public var version:Int32
    public var callback:(Int32,DataBase) throws ->Void
    public init(version:Int32,callback:@escaping (Int32,DataBase) throws ->Void) {
        self.version = version
        self.callback = callback
    }
}

public class DataBaseUpdate{
    public var callbacks:[DataBaseUpdateCallback]
    public init(callbacks:[DataBaseUpdateCallback]) {
        self.callbacks = callbacks
    }
    public func update(db:DataBase) throws {
        let calls = self.callbacks.sorted { l, r in
            l.version < r.version
        }
        for i in calls{
            if i.version > db.version{
                try i.callback(i.version,db)
            }
        }
    }
}


public struct DataBaseConfiguration{
    public var name:String
    public var models:[TableDeclare]
    public func configure() throws ->DataBase{
        let db = try DataBase(name: name, readonly: false, writeLock: false)
        do{
            db.begin()
            let a = db.foreignKeys
            db.foreignKeys = false
            for i in models{
                if try !db.tableExist(name: i.name){
                    try i.create(db: db)
                }else{
                    try i.updates?.update(db: db)
                }
            }
            let v = models.map({$0.version}).max() ?? 0
            db.version = v;
            db.foreignKeys = a
            db.commit()
            return db
        }catch{
            db.rollback()
            throw error
        }
        
    }
    public init(name:String,models:[TableDeclare]){
        self.name = name
        self.models = models
    }
}
