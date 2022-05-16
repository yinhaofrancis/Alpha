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
    
}
public struct KOL:Module{
    public var memory: Memory = .Normal
    
    public var name: String = "KOL"
    
    private static var dbConfig:DataBaseConfiguration = {
        DataBaseConfiguration(name: "KOL", models: [
            One().declare
        ])
    }()
    
    @DBWorkFlow(configure: KOL.dbConfig)
    var workflow:DataBaseWorkFlow
    
    public var entries: [String : ModuleEntry]{
        ClosureEntry(name: .KLO1) { param in
            self.workflow.workflow { db in
                let o = One()
                o.a = Int(arc4random())
                o.b = "dsdada"
                try o.tableModel.insert(db: db)
            }
        }
        ClosureEntry(name: .KLO2) { param in
            
        }
        ClosureEntry(name: .KLO3) { param in
            
        }
        ClosureEntry(name: .KLO4) { param in
            
        }
    }
    
    
}
