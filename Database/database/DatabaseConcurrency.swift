//
//  DatabaseConcurrency.swift
//  Ammo
//
//  Created by wenyang on 2022/5/28.
//

import Foundation

@available(iOS 13.0.0, *)
public actor DatabaseConcurrency{
    
    private static var map:[String:DatabaseConcurrency] = [:]
    
    static func getDatabase(name:String)->DatabaseConcurrency{
        if let m = map[name]{
            return m
        }else{
            map[name] = DatabaseConcurrency(DatabaseName: name)
            return map[name]!
        }
    }
    
    private var Database:Database
    
    public init(DatabaseName:String){
        self.Database = DatabaseWorkflow.getWorkFlow(name: DatabaseName).wdb
    }
    public func create(type:DatabaseProtocol.Type) async throws{
        try await Task {
            do{
                self.Database.begin()
                _ = try type.init(db: self.Database)
                self.Database.commit()
            }catch{
                self.Database.rollback()
                throw error
            }
        }.value
    }
    public func add(model:DatabaseProtocol) async throws{
        try await Task {
            do{
                self.Database.begin()
                try model.tableModel.insert(db: self.Database)
                self.Database.commit()
            }catch{
                do{
                    try model.tableModel.update(db: self.Database)
                    self.Database.commit()
                }catch{
                    self.Database.rollback()
                    throw error
                }
            }
        }.value
    }
    public func remove(model:DatabaseProtocol) async throws{
        try await Task{
            do{
                self.Database.begin()
                try model.tableModel.delete(db: self.Database)
                self.Database.commit()
            }catch{
                self.Database.rollback()
                throw error
            }
        }.value
    }
    public func select<T:DatabaseProtocol>(
        condition:QueryCondition?) async throws ->[T]{
            try await Task{
                try T.select(db: self.Database, condition: condition)
            }.value
    }
    public func select<T:DatabaseFetchObject>(
        fetch:DatabaseFetchObject.Fetch,
        param:[String:DBType]? = nil) async throws ->[T]{
            try await Task {
                try fetch.query(db: self.Database)
            }.value
    }
}


@available(iOS 13.0.0, *)
@globalActor
public actor DatabaseActor:GlobalActor{
    
    public static var shared: DatabaseActor = DatabaseActor()
    
    public typealias ActorType = DatabaseActor
    
    
}

@available(iOS 13.0.0, *)
public struct DatabaseSet<T:DatabaseProtocol>{
    
    private var task:DatabaseConcurrency
    
    public var condition:QueryCondition?
    
    public var param:[String:DBType]?
    
    @DatabaseActor
    public var array:[T]{
        get async throws{
            try await self.task.select(condition: self.condition)
        }
    }
    public func add(model:T) async throws {
        try await self.task.add(model: model)
    }
    public func remove(model:T) async throws{
        try await self.task.remove(model: model)
    }
    public init(Database:String) async throws{
        self.task = DatabaseConcurrency.getDatabase(name: Database)
        try await self.task.create(type: T.self)
        
    }
}
@available(iOS 13.0.0, *)
public struct DatabaseFetchSet<T:DatabaseFetchObject>{
    @DatabaseActor
    public var array:[T]{
        get async throws{
            try await self.task.select(fetch: self.fetch, param: self.param)
        }
    }
    public init(Database:String,fetch:DatabaseFetchObject.Fetch){
        self.fetch = fetch
        self.task = DatabaseConcurrency.getDatabase(name: Database)
    }
    
    private var task:DatabaseConcurrency
    
    public var fetch:DatabaseFetchObject.Fetch
    
    public var param:[String:DBType]?
}
