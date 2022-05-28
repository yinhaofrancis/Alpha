//
//  DataBaseConcurrency.swift
//  Ammo
//
//  Created by wenyang on 2022/5/28.
//

import Foundation

@available(iOS 13.0.0, *)
public actor DataBaseConcurrency{
    
    private static var map:[String:DataBaseConcurrency] = [:]
    
    static func getDatabase(name:String)->DataBaseConcurrency{
        if let m = map[name]{
            return m
        }else{
            map[name] = DataBaseConcurrency(databaseName: name)
            return map[name]!
        }
    }
    
    private var database:DataBase
    
    public init(databaseName:String){
        self.database = DataBaseWorkFlow.getWorkFlow(name: databaseName).wdb
    }
    public func create(type:DataBaseProtocol.Type) async throws{
        try await Task {
            do{
                self.database.begin()
                _ = try type.init(db: self.database)
                self.database.commit()
            }catch{
                self.database.rollback()
                throw error
            }
        }.value
    }
    public func add(model:DataBaseProtocol) async throws{
        try await Task {
            do{
                self.database.begin()
                try model.tableModel.insert(db: self.database)
                self.database.commit()
            }catch{
                do{
                    try model.tableModel.update(db: self.database)
                    self.database.commit()
                }catch{
                    self.database.rollback()
                    throw error
                }
            }
        }.value
    }
    public func remove(model:DataBaseProtocol) async throws{
        try await Task{
            do{
                self.database.begin()
                try model.tableModel.delete(db: self.database)
                self.database.commit()
            }catch{
                self.database.rollback()
                throw error
            }
        }.value
    }
    public func select<T:DataBaseProtocol>(
        condition:QueryCondition?) async throws ->[T]{
            try await Task{
                try T.select(db: self.database, condition: condition)
            }.value
    }
    public func select<T:DataBaseFetchObject>(
        fetch:DataBaseFetchObject.Fetch,
        param:[String:DBType]? = nil) async throws ->[T]{
            try await Task {
                try fetch.query(db: self.database)
            }.value
    }
}


@available(iOS 13.0.0, *)
@globalActor
public actor DataBaseActor:GlobalActor{
    
    public static var shared: DataBaseActor = DataBaseActor()
    
    public typealias ActorType = DataBaseActor
    
    
}

@available(iOS 13.0.0, *)
public struct DataBaseSet<T:DataBaseProtocol>{
    
    private var task:DataBaseConcurrency
    
    public var condition:QueryCondition?
    
    public var param:[String:DBType]?
    
    @DataBaseActor
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
    public init(database:String) async throws{
        self.task = DataBaseConcurrency.getDatabase(name: database)
        try await self.task.create(type: T.self)
        
    }
}
@available(iOS 13.0.0, *)
public struct DataBaseFetchSet<T:DataBaseFetchObject>{
    @DataBaseActor
    public var array:[T]{
        get async throws{
            try await self.task.select(fetch: self.fetch, param: self.param)
        }
    }
    public init(database:String,fetch:DataBaseFetchObject.Fetch){
        self.fetch = fetch
        self.task = DataBaseConcurrency.getDatabase(name: database)
    }
    
    private var task:DataBaseConcurrency
    
    public var fetch:DataBaseFetchObject.Fetch
    
    public var param:[String:DBType]?
}
