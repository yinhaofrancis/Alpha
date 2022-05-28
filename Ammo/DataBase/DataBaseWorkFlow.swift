//
//  DataBaseWorkFlow.swift
//  Ammo
//
//  Created by hao yin on 2022/4/26.
//

import Foundation

public class DataBaseWorkFlow{
    fileprivate var writeQueue:DispatchQueue = DispatchQueue(label: "DataBaseWorkFlow", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    public private(set) var wdb:DataBase
    private var semaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
    public init(name:String) throws {
        self.wdb = try DataBase(name: name, readonly: false, writeLock: true)
    }
    public func workflow(_ callback:@escaping (DataBase) throws ->Void){
        self.writeQueue.async(execute: DispatchWorkItem(qos: .userInitiated, flags: .barrier, block: {
            try? self.runWork(callback: callback)
        }))
    }
    fileprivate func runWork(callback:(DataBase) throws ->Void) throws{
        do{
            self.wdb.begin()
            try callback(self.wdb)
            self.wdb.commit()
        }catch{

            self.wdb.rollback()
            throw error
        }
    }
    
    public func syncWorkflow(_ callback:@escaping (DataBase) throws ->Void) throws{
        var e:Error?
        self.writeQueue.sync(execute: DispatchWorkItem(qos: .userInitiated, flags: .barrier, block: {
            do{
                try self.runWork(callback: callback)
            }catch{
                e = error
            }
            
        }))
        if let ee = e{
            throw ee
        }
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
        var e:Error?
        let db = try DataBase(url: self.wdb.url, readonly: true, writeLock: false)
        self.writeQueue.sync {
            do{
                try callback(db)
            }catch{
                e = error
            }
            db.close()
        }
        if let ee = e{
            throw ee
        }
    }
    deinit{
        self.wdb.close()
    }
    
    private static var lock:DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private static var workFlow:[String:DataBaseWorkFlow] = [:]
    
    public static func getWorkFlow(name:String)->DataBaseWorkFlow{
        defer{
            lock.signal()
        }
        lock.wait()
        guard let a = DataBaseWorkFlow.workFlow[name] else {
            DataBaseWorkFlow.workFlow[name] = try! DataBaseWorkFlow(name: name)
            return DataBaseWorkFlow.workFlow[name]!
        }
        return a
    }
}

@propertyWrapper
public struct DBWorkFlow{
    
    
    
                                 
    public var name:String
    
    public var wrappedValue:DataBaseWorkFlow{
        
        return DataBaseWorkFlow.getWorkFlow(name: self.name)
    }
    
    public init(name:String){
        self.name = name
    }
}



@propertyWrapper
public class DBContent<T:DataBaseProtocol>{
    
    public var wrappedValue: Array<T>{
        if(self.origin.count == 0){
            self.sync()
        }
        return self.origin
    }
    private var origin:Array<T> = []
    private var work:DataBaseWorkFlow
    private var lock:DispatchSemaphore = DispatchSemaphore(value: 1)
    public init(databaseName:String){
        self.work = DataBaseWorkFlow.getWorkFlow(name: databaseName)
        self.work.workflow { db in
            _ = try T.init(db: db)
        }
    }
    public func add(content:T){
        self.lock.wait()
        self.origin.append(content)
        self.work.workflow { db in
            try content.tableModel.insert(db: db)
        }
        self.lock.signal()
    }
    public func remove(content:T) throws{
        self.lock.wait()
        var array:[T] = []
        try self.work.syncWorkflow { db in
            try content.tableModel.delete(db: db)
            array = try self.query(db: db)
        }
        self.origin = array
        self.lock.signal()
    }
    public func remove(index:Int) throws {
        if origin.count > index{
            try self.remove(content: self.origin[index])
        }
    }
    private func query(db:DataBase) throws ->[T]{
        return try T.select(db: db)
    }
    public func sync(){
        var array:[T] = []
        try? self.work.syncQuery{ db in
            array = try self.query(db: db)
        }
        self.origin = array
    }
}

@propertyWrapper
public struct DBFetchContent<T:DataBaseFetchObject>{
    public var wrappedValue:[T]{
        return self.origin
    }
    private var origin:[T] = []
    private var fetch:DataBaseFetchObject.Fetch
    private var work:DataBaseWorkFlow
    private var param:[String:DBType]?
    public init(databaseName:String,fetch:DataBaseFetchObject.Fetch,param:[String:DBType]? = nil){
        self.fetch = fetch
        self.param = param
        self.work = DataBaseWorkFlow.getWorkFlow(name: databaseName)
        self.query()
    }
    public mutating func query(){
        var arr:[T] = []
        let fetc = self.fetch
        let param = self.param
        try? self.work.syncQuery { db in
            arr = try fetc.query(db: db,param: param)
        }
        self.origin = arr
    }
}

@propertyWrapper
public struct DBFetchView<T,V:DataBaseFetchViewProtocol> where T == V.Objects{
    public var view:V
    public var work:DataBaseWorkFlow
    public var condition:QueryCondition?{
        didSet{
            self.param = nil
        }
    }
    public var param:[String:DBType]?
    public init(view:V,name:String){
        self.view = view
        self.work = DataBaseWorkFlow.getWorkFlow(name: name)
        self.work.workflow { db in
            try V().createView(db: db)
        }
    }
    
    public var wrappedValue: [T]{
        var a:[T] = []
        let v = self.view
        try? self.work.syncQuery { db in
            
            a = try v.query(db: db,condition: self.condition,param: self.param)
        }
        return a
        
    }
}

@propertyWrapper
public class DBObject<T:DataBaseProtocol>{
    public var wrappedValue: T{
        get{
            let o = originValue
            try? self.work.syncQuery { db in
                try o.tableModel.select(db: db)
            }
            return o
        }
        set{
            self.originValue = newValue
            
        }
    }
    public var inDB:Bool{
        var b:Bool = false
        try? self.work.syncQuery { db in
            b = try self.originValue.tableModel.InDB(db: db)
        }
        return b
    }
    public func sync() throws{
        try self.work.syncWorkflow({ db in
            do{
                try self.originValue.tableModel.insert(db: db)
            }catch{
                try self.originValue.tableModel.update(db: db)
            }
        })
    }
    public var originValue: T
    private var work:DataBaseWorkFlow
    public init(wrappedValue: T,databaseName:String){
        self.originValue = wrappedValue
        self.work = DataBaseWorkFlow.getWorkFlow(name: databaseName)
    }
}
