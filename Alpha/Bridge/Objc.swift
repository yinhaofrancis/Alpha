//
//  Objc.swift
//  Alpha
//
//  Created by hao yin on 2021/9/6.
//

import Foundation

@objcMembers public class AlphaBridge:NSObject{
    private var pool:DataBasePool
    @objc public init(name:String) throws{
        self.pool = try DataBasePool(name: name)
    }
    public func save(name:String,obj:[String:Any]){
        self.pool.writeSync { db in
            try db.save(name, JSON(obj))
        }
    }
    public func query(name:String,condition:String?,value:[String:String]?)->[[String:Any]]{
        var result:[[String:Any]] = []
        self.pool.readSync { db in
            let json = try db.query(name: name, conditionString: condition, value: value ?? [:])
            result = json.filter { m in
                m.json is Dictionary<String,Any>
            }.map { m in
                m.json as! Dictionary<String,Any>
            }
        }
        return result
    }
    public func delete(name:String,rowid:Int){
        self.pool.writeSync { db in
            try db.delete(name: name, rowid: rowid)
        }
    }
}
