//
//  DatabaseTest.swift
//  AlphaTests
//
//  Created by hao yin on 2022/4/18.
//

import Foundation
import XCTest
import Ammo

public class DatabaseTest: XCTestCase {
    
    
    func testDataBase() throws{
        let succes = XCTestExpectation(description: "end")
        let wbfl = try DataBaseWorkFlow(name: "dddt")
        wbfl.workflow { db in
            let a = Ob()
            a.tableModel.drop(db: db)
            try a.declare.create(db: db)
            
            for i in 0 ..< 80 {
                a.i = i * 2
                a.d = i * 100
                a.ki = "dadada王🉑️\(i)"
                a.da = "dadada王🉑️\(i * 100)".data(using: .utf8)
                a.ea = ["ddd":"dddd","a":i + 1]
                try a.tableModel.insert(db: db)
                try a.tableModel.update(db: db)
            }
            
            let b = Oc()
            b.tableModel.drop(db: db)
            try b.declare.create(db: db)
            
            for i in 0 ..< 80 {
                b.i = 80 - i
                b.d = i * 100
                b.ki = "dadada王🉑️\(i)"
                b.da = "dadada王🉑️\(i * 100)".data(using: .utf8)
                b.ee = Date()
                try b.tableModel.insert(db: db)
                try b.tableModel.update(db: db)
            }
            try Ob.delete(db: db, condition: QueryCondition.Key(key: "a") == QueryCondition.Key(key: "10"))
        }
        try wbfl.query { db in
            var a = Ob()
            let mm = a.tableModel
            mm.declare[0].origin = 1
            mm.declare[1].origin = 2
            a.tableModel = mm
            
            a.d = 99999
            a.i = 19
            
            try mm.select(db: db)
            let tm:[Ob] = try Ob.select(db: db,condition: QueryCondition.Key(key: "a") != QueryCondition.Key(key: "10"))
            print(tm)
            let tm1:[Ob] = try Ob.select(db: db,condition: QueryCondition.in(key: .init(key: "a"), value: [1,10,100,1000]))
            print(tm1)
            let tm2:[Ob] = try Ob.select(db: db)
            print(tm2)
            succes.fulfill()
        }
        self.wait(for: [succes], timeout: 5)
        print("end")
    }
    func testbkDataBase() throws {
        let db = try DataBase(name: "dddt")
        let bdb = try DataBaseBackUp(name: "ddtb", database: db);
        try bdb.backup()
        db.close()
        db.deleteDatabaseFile()
        
    }
    func testrsDataBase() throws {
        let rsd = try DataBaseRestore(name: "dddt", backup: "ddtb")
        try rsd.restore()
    }
    func testConditionDataBase() throws {
        let a = JSONModel(object: ["a":1,"dd":2,"e":3])
        print(a.a)
        let s:JSONModel = ["ddd":"dddd","a":1]
        print(s.jsonString)
    }
    
    func testQueryDataBase() throws {
        let db = try DataBase(name: "dddt")
        let tm:[oQ] = try oQ.fetch(table: Ob.self).whereCondition(condition: QueryCondition(condition: "a % 2 = 0")).query(db: db)
        print(tm)
        
        let tm2:[ocl] = try ocl.fetch(table: Ob.self)
            .joinQuery(join: .crossJoin, table: Oc.self)
            .whereCondition(condition: QueryCondition.Key(key: "a", table: Ob.self) == QueryCondition.Key(key: "a", table: Oc.self))
            .orderBy(key: .init(key: "a", table: Ob.self), desc: true)
            .query(db: db)
        print(tm2)
        
        
        let tm3:[Ob] = try Ob.select(db: db, condition: QueryCondition.Key(jsonKey: "e", keypath: "$.a") < QueryCondition.Key(key: "10"))
        print(tm3)
        db.close()
    }
    
    func testFunction() throws{
        let dnwf = try DataBaseWorkFlow(name: "dddt")
        dnwf.workflow { db in
            let tm1:[occ] = try occ.fetch(table: Ob.self).whereCondition(condition: QueryCondition(condition: "a % 2 = 0")).query(db: db)
            print("---occ---")
            print(tm1)
            print("---occ---")
        }
        
    }
    func testJSONSave() throws{
        let db = try DataBase(name: "dddt")
        try JSONObject().declare.create(db: db)
        for i in 0 ..< 1000 {
            try JSONObject(json: ["a\(i)":"a","b":"b\(i)","c":i,"d":[i + 1,i + 2,i + 3,i + 4,i + 5,i + 6,i + 7]]).save(db: db)
        }
        
        let jsons:[JSONObject] = try JSONObject.select(db: db, condition: QueryCondition.in(key: QueryCondition.Key.init(jsonKey: "json", keypath: "$.d[0]"), value: [1,2,10,100,998,99]))
        print(jsons)
        db.close()
    }
}

public class oQ:DataBaseFetchObject,CustomStringConvertible{
    @QueryColume(colume: "a")
    var a:Int? = nil
    
    @QueryColume(colume: "c")
    var c:String? = nil
    
    public var description: String{
        return "\(String(describing: a)),\(String(describing: c))"
    }
}

public class occ:DataBaseFetchObject,CustomStringConvertible{
    @QueryColume(function: "max", colume: "a")
    var a:Int? = nil
    
    @QueryColume(function: "count", colume: "c")
    var c:Int? = nil
    
    public var description: String{
        return "\(String(describing: a)),\(String(describing: c))"
    }
}

public class ocl:DataBaseFetchObject,CustomStringConvertible{
    @QueryColume(colume: "a", type: Ob.self)
    var ba:Int? = nil
    @QueryColume(colume: "c", type: Ob.self)
    var bc:String? = nil
    @QueryColume(colume: "a", type: Oc.self)
    var ca:Int? = nil
    @QueryColume(colume: "c", type: Oc.self)
    var cc:String? = nil
    @QueryColume(colume: "b", type: Oc.self)
    var cb:Int? = nil
    @QueryColume(colume: "e", type: Ob.self)
    var json:JSONModel? = nil
    @QueryColume(colume: "e", type: Oc.self)
    var fdate:Date? = nil
    public var description: String{
        return "\(ba ?? 0)|\(bc ?? "null")|\(ca ?? 0)|\(cc ?? "null")|\(cb ?? 0)|\(json ?? "null")|\(fdate as Any)"
    }
}

public class Ob:DataBaseObject,CustomStringConvertible{
    @Col(name:"a",primaryKey:true)
    var i:Int = 0
    
    @Col(name:"b")
    var d:Int? = nil
    
    @Col(name:"c")
    var ki:String = ""
    
    @Col(name:"d")
    var da:Data? = nil
    
    @Col(name:"e")
    var ea:JSONModel? = nil
    public var description: String{
        return "\(i),\(String(describing: d)),\(ki),\(String(describing: da)),\(String(describing: self.ea))"
    }
}

public class Oc:DataBaseObject,CustomStringConvertible{
    @Col(name:"a",primaryKey:true)
    var i:Int = 0
    
    @FK(refKey: "b",refTable:Ob.self)
    @Col(name:"b")
    var d:Int? = nil
    
    @Col(name:"c")
    var ki:String = ""
    
    @Col(name:"d")
    var da:Data? = nil
    
    @Col(name:"e")
    var ee:Date? = nil
    
    public var description: String{
        return "\(i),\(String(describing: d)),\(ki),\(String(describing: da)),\(String(describing: self.ee))"
    }
}
