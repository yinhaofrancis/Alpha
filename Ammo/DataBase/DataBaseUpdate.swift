//
//  DataBaseUpdate.swift
//  Ammo
//
//  Created by hao yin on 2022/5/26.
//

import Foundation

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
    public typealias CallbackBlock = (DataBase) throws ->Void
    public var version:Int32
    public var callback:CallbackBlock
    public init(version:Int32,callback:@escaping CallbackBlock) {
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
    public func update(db:DataBase,model:DataBaseProtocol.Type) throws->Int32 {
        let calls = self.callbacks.sorted { l, r in
            l.version < r.version
        }
        var v:Int32 = 0
        let version = try model.databaseVersionNum(db: db)
        for i in calls{
            if i.version > version{
                try i.callback(db)
                v = max(v, i.version)
            }
        }
        return v
    }
}
