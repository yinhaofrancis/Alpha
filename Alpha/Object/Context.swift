//
//  Context.swift
//  Alpha
//
//  Created by hao yin on 2021/9/10.
//

import Foundation

public class Context{
    public var pool:DataBasePool = DataBasePool.default
    public var cache:[String:[String:Object]] = [:]
    public init(name:String = "") throws {
        if name.count > 0{
            self.pool = try DataBasePool(name: name)
        }
    }
    public func request<T:Object>(request:ObjectRequest<T>,keyMap:[String:DataType] = [:])->[T]{
        var results:[T] = []
        self.pool.readSync { db in
            results = try request.query(db: db, valueMap: keyMap)
            for i in results{
                i.context = self
            }
        }
        return results
    }
    
    public func query<T:Object>(objct:T){
        if (objct.objectId.count > 0){
            self.pool.readSync { db in
                try objct.queryObject(db: db)
                objct.context = self
            }
        }
    }
    public func save<T:Object>(objct:T){
        objct.context = self
        self.pool.write{ db in
            try objct.save(db: db)
        }
    }
    public func create<T:Object>(type:T.Type)->T{
        let obj = T()
        obj.context = self
        self.pool.write { db in
            try obj.checkObject(db: db)
        }
        return obj
    }
    public func delete<T:Object>(objct:T){
        objct.context = nil
        self.pool.write{ db in
            try objct.delete(db: db)
            
        }
    }
    public func loadFunction(function:Function){
        self.pool.write { db in
            db.addFunction(function: function)
        }
    }
}
