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
}

public struct DataBaseUpdateCallback{
    public var version:Int32
    public var callback:(Int32,DataBase) throws ->Void
}

public class DataBaseUpdate{
    public var callbacks:[DataBaseUpdateCallback] = []
    public init() {}
    public var origin:DataBaseUpdate{
        return self
    }
    public func callback(db:DataBase) throws {
        let calls = self.origin.callbacks.sorted { l, r in
            l.version < r.version
        }
        for i in calls{
            if i.version > db.version{
                try i.callback(i.version,db)
            }
        }
    }
}

@propertyWrapper
public class DBUpdate<T:DataBaseUpdate>:DataBaseUpdate{
    public var wrappedValue: T
    public override var origin: DataBaseUpdate{
        return wrappedValue.origin
    }
    public init(wrappedValue: T,version:Int32,callback:@escaping (Int32,DataBase)->Void){
        self.wrappedValue = wrappedValue
        super.init()
        self.origin.callbacks.append(DataBaseUpdateCallback(version: version, callback: callback))
    }
}

public struct DataBaseConfiguration{
    public var name:String
    public var models:[DataBaseObject]
    public func configure() throws ->DataBase{
        let db = try DataBase(name: name, readonly: false, writeLock: false)
        do{
            db.begin()
            for i in models{
                if try !db.tableExist(name: i.declare.name){
                    try i.declare.create(db: db)
                }else{
                    try i.updateDB(db: db)
                }
            }
            let v = models.map({$0.version}).max() ?? 0
            db.version = v;
            db.commit()
            return db
        }catch{
            db.rollback()
            throw error
        }
        
    }
    public init(name:String,models:[DataBaseObject]){
        self.name = name
        self.models = models
    }
}
