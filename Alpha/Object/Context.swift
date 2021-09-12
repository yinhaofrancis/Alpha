//
//  Context.swift
//  Alpha
//
//  Created by hao yin on 2021/9/10.
//

import Foundation

public class Context{
    public let pool:DataBasePool
    public init(name:String) throws {
        self.pool = try DataBasePool(name: name)
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
        self.pool.readSync { db in
            try objct.queryObject(db: db)
            objct.context = self
        }
    }
    public func save<T:Object>(objct:T){
        objct.context = self
        self.pool.writeSync{ db in
            try objct.save(db: db)
        }
    }
    public func create<T:Object>(type:T.Type)->T{
        let obj = T()
        self.pool.writeSync { db in
            try obj.checkObject(db: db)
            obj.context = self
        }
        return obj
    }
}
