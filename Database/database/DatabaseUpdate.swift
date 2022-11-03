//
//  DatabaseUpdate.swift
//  Ammo
//
//  Created by hao yin on 2022/5/26.
//

import Foundation

@resultBuilder
public struct DBUpdate{
    public static func buildBlock(_ components: DatabaseUpdateCallback...) -> DatabaseUpdate {
        DatabaseUpdate(callbacks: components)
    }
    public static func buildBlock(_ components:DatabaseUpdateCallback.CallbackBlock...) -> DatabaseUpdate {
        
        var a:[DatabaseUpdateCallback] = []
        for i in 1 ... components.count{
            a.append(DatabaseUpdateCallback(version: Int32(i), callback: components[i - 1]))
        }
        
        return DatabaseUpdate(callbacks: a)
    }
}
public struct DatabaseUpdateCallback{
    public typealias CallbackBlock = (Database) throws ->Void
    public var version:Int32
    public var callback:CallbackBlock
    public init(version:Int32,callback:@escaping CallbackBlock) {
        self.version = version
        self.callback = callback
    }
}

@resultBuilder
public struct DatabaseUpdateBuilder{
    public static func buildBlock(_ components: DatabaseUpdateCallback...) -> [DatabaseUpdateCallback] {
        return components
    }
    
}
public class DatabaseUpdate{
    public var callbacks:[DatabaseUpdateCallback]
    public init(callbacks:[DatabaseUpdateCallback]) {
        self.callbacks = callbacks
    }
    public init(@DatabaseUpdateBuilder buider:()->[DatabaseUpdateCallback]) {
        self.callbacks = buider()
    }
    public func update(db:Database,model:DatabaseProtocol.Type) throws->Int32 {
        let calls = self.callbacks.sorted { l, r in
            l.version < r.version
        }
        var v:Int32 = 0
        let version = try model.DatabaseVersionNum(db: db)
        for i in calls{
            if i.version > version{
                try i.callback(db)
                v = max(v, i.version)
            }
        }
        return v
    }
}
