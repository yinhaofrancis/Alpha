//
//  KOL.swift
//  Data
//
//  Created by hao yin on 2022/5/16.
//

import Foundation
import Ammo

extension EventKey{
    public static var KLO1 = EventKey(rawValue: "KLO1")
    public static var KLO2 = EventKey(rawValue: "KLO2")
    public static var KLO3 = EventKey(rawValue: "KLO3")
    public static var KLO4 = EventKey(rawValue: "KLO4")
}
public class One:DataBaseObject{
    
    @Col(name: "a", primaryKey: true)
    var a:Int = 1
    
    @Col(name:"b")
    var b:String? = nil
    
    @Col(name:"c")
    var c:String? = nil
    
    var update:DataBaseUpdate = DataBaseUpdate {
        DataBaseUpdateCallback(version: 1, callback: { v, db in
            One().declare.add(colume: One()._c, db: db)
        })
    }
    
}
public struct KOL:Module{
    
    public init() {
        
    }
    public static var memory: Memory = .Normal
    
    public static var name: String = "KOL"
    
    private static var dbConfig:DataBaseConfiguration = {
        DataBaseConfiguration(name: "KOL", models: [
            One().declare
        ])
    }()
    
    @DBWorkFlow(configure: KOL.dbConfig)
    var workflow:DataBaseWorkFlow
    
    @ModuleState
    var count:Int64 = 0
    
    public var entries: [String : ModuleEntry]{
        ClosureEntry(name: .onCreate) { param,ret  in
            try? self.workflow.syncQuery({ db in
                self.count = try One().tableModel.count(db: db)
            })
        }
        ClosureEntry(name: .KLO1) { param,ret in
            self.workflow.workflow { db in
                let o = One()
                o.a = Int(count)
                count += 1
                o.b = "dsdada"
                try o.tableModel.insert(db: db)
                ret?(["d":"dsds"])
            }
        }
        ClosureEntry(name: .KLO2) { param,ret in
            
        }
        ClosureEntry(name: .KLO3) { param,ret in
            
        }
        ClosureEntry(name: .KLO4) { param,ret in
            
        }
    }
}
