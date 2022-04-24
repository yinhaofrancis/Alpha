//
//  DataBaseViewModel.swift
//  Ammo
//
//  Created by hao yin on 2022/4/24.
//

import Foundation

public class DataBaseViewObject{
    public var declare:[String:FetchColume]{
        return Mirror(reflecting: self).children.filter { kv in
            (kv.value as? FetchColume) != nil
        }.reduce(into: [:]) { partialResult, kv in
            let fc = kv.value as! FetchColume
            partialResult[fc.align ?? fc.colume] = fc
        }
    }
    public static var name:String{
        return NSStringFromClass(self).replacingOccurrences(of: ".", with: "_")
    }
    public static func createView(db:DataBase){
        
        let c:[String] = []
        let ob = Self()
        let t = ob.declare.reduce(into: c) { partialResult, k in
            if !partialResult.contains(k.value.colume){
                partialResult.append(k.value.colume)
            }
        }
        let sql = "create view \(Self.name) select \(ob.declare.map({$0.value.colume})) from \(t.joined(separator: ","))"
        db.exec(sql: sql)
    }
    required init() {}
}
