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
    public func syncWorkflow(_ callback:@escaping (DataBase) throws ->Void){
        self.writeQueue.sync(execute: DispatchWorkItem(qos: .userInitiated, flags: .barrier, block: {
            do{
                self.wdb.begin()
                try callback(self.wdb)
                self.wdb.commit()
            }catch{
                print(error)
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
    public func syncQuery(_ callback:@escaping (DataBase) throws ->Void) throws{
        let db = try DataBase(url: self.wdb.url, readonly: true, writeLock: false)
        self.writeQueue.sync {
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
    
    private static var lock:DispatchSemaphore = DispatchSemaphore(value: 1)
                                 
    public var name:String
    
    public var wrappedValue:DataBaseWorkFlow{
        
        return DBWorkFlow.createWorkFlow(name: self.name)
    }
    
    public init(name:String){
        self.name = name
    }
    fileprivate static func createWorkFlow(name:String)->DataBaseWorkFlow{
        defer{
            lock.signal()
        }
        lock.wait()
        guard let a = DBWorkFlow.workFlow[name] else {
            DBWorkFlow.workFlow[name] = try! DataBaseWorkFlow(name: name)
            return DBWorkFlow.workFlow[name]!
        }
        return a
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

@resultBuilder
public struct DataBaseUpdateBuilder{
    public static func buildBlock(_ components: DataBaseUpdateCallback...) -> [DataBaseUpdateCallback] {
        return components
    }
    
}
public class DataBaseUpdate{
    public var callbacks:[DataBaseUpdateCallback]
    public init(callbacks:[DataBaseUpdateCallback]) {
        self.callbacks = callbacks
    }
    public init(@DataBaseUpdateBuilder buider:()->[DataBaseUpdateCallback]) {
        self.callbacks = buider()
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


@propertyWrapper
public class DBContent<T:DataBaseObject>{
    
    public var wrappedValue: Array<T>{
        if(self.origin.count == 0){
            self.sync()
        }
        return self.origin
    }
    private var origin:Array<T> = []
    private var work:DataBaseWorkFlow
    public init(name:String){
        self.work = DBWorkFlow.createWorkFlow(name: name)
        self.work.syncWorkflow { db in
            _ = try T.init(db: db)
        }
    }
    public func add(content:T){
        self.origin.append(content)
        self.work.workflow { db in
            try content.tableModel.insert(db: db)
        }
    }
    public func remove(content:T){
        var array:[T] = []
        self.work.syncWorkflow { db in
            try content.tableModel.delete(db: db)
            array = try self.query(db: db)
        }
        self.origin = array
    }
    public func remove(index:Int){
        if origin.count > index{
            self.remove(content: self.origin[index])
        }
    }
    private func query(db:DataBase) throws ->[T]{
        return try T.select(db: db)
    }
    public func sync(){
        var array:[T] = []
        self.work.syncWorkflow { db in
            array = try self.query(db: db)
        }
        self.origin = array
    }
}
