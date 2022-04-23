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
        let db = try DataBase(name: "dddt")
        let a = Ob()
        try a.declare.create(db: db)
        
        for i in 0 ..< 80 {
            a.i = i * 2
            a.d = i * 100
            a.ki = "dadada王🉑️\(i)"
            a.da = "dadada王🉑️\(i * 100)".data(using: .utf8)
            try a.tableModel.insert(db: db)
            try a.tableModel.update(db: db)
        }
        
        let b = Oc()
        try b.declare.create(db: db)
        
        for i in 0 ..< 80 {
            b.i = 80 - i
            b.d = i * 100
            b.ki = "dadada王🉑️\(i)"
            b.da = "dadada王🉑️\(i * 100)".data(using: .utf8)
            try b.tableModel.insert(db: db)
            try b.tableModel.update(db: db)
        }
        let mm = a.tableModel
        mm.declare[0].origin = 1
        mm.declare[1].origin = 2
        a.tableModel = mm
        a.d = 99999
        a.i = 19
        
        try mm.select(db: db)
        let tm:[Ob] = try Ob.select(db: db,condition: QueryCondition.Key(key: "a") != QueryCondition.Key(key: "10"))
        print(tm)
        let tm1:[Ob] = try Ob.select(db: db,condition: QueryCondition.in(key: .init(key: "a"), value: "1","10","100","1000"))
        print(tm1)
//        try Ob.delete(db: db, condition: QueryCondition.Key(key: "dd") != QueryCondition.Key(key: "10"))
//        let tm2:[Ob] = try Ob.select(db: db)
//        print(tm2)
        db.close()
        
        
        
    }
    func testbkDataBase() throws {
        let db = try DataBase(name: "dddt")
        let bdb = try BackUpDataBase(name: "ddtb", database: db);
        try bdb.backup()
        db.close()
        db.deleteDatabaseFile()
        
    }
    func testrsDataBase() throws {
        let rsd = try RestoreDataBase(name: "dddt", backup: "ddtb")
        try rsd.restore()
    }
    func testConditionDataBase() throws {
        
        let a = QueryCondition.Key(key:"a") != QueryCondition.Key(key:"10") && QueryCondition.Key(key:"b") != QueryCondition.Key(key:"10")
        XCTAssert(a.condition == "a <> 10 and b <> 10")
    }
    
    func testQueryDataBase() throws {
        let db = try DataBase(name: "dddt")
        let tm:[oQ] = try oQ.fetch(table: Ob.self).whereCondition(condition: QueryCondition(condition: "a % 2 = 0")).query(db: db)
        print(tm)
        
        let tm1:[occ] = try occ.fetch(table: Ob.self).whereCondition(condition: QueryCondition(condition: "a % 2 = 0")).query(db: db)
        print(tm1)
        
        let tm2:[ocl] = try ocl.fetch(table: Ob.self)
            .joinQuery(join: .leftJoin, table: Oc.self)
            .whereCondition(condition: QueryCondition.Key(key: "a", table: Ob.self) == QueryCondition.Key(key: "a", table: Oc.self))
            .orderBy(key: .init(key: "a", table: Ob.self), desc: true)
            .query(db: db)
        print(tm2)
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
    @QueryColume(colume: "max(a)")
    var a:Int? = nil
    
    @QueryColume(colume: "count(c)")
    var c:Int? = nil
    
    public var description: String{
        return "\(a),\(c)"
    }
}

public class ocl:DataBaseFetchObject,CustomStringConvertible{
    @QueryColume(colume: "a", type: Ob.self,align:"ba")
    var ba:Int? = nil
    @QueryColume(colume: "c", type: Ob.self,align:"bc")
    var bc:String? = nil
    @QueryColume(colume: "a", type: Oc.self,align:"ca")
    var ca:Int? = nil
    @QueryColume(colume: "c", type: Oc.self,align:"cc")
    var cc:String? = nil
    @QueryColume(colume: "b", type: Oc.self,align:"cb")
    var cb:Int? = nil
    public var description: String{
        return "\(ba ?? 0)|\(bc ?? "null")|\(ca ?? 0)|\(cc ?? "null")|\(cb ?? 0)"
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
    
    public var description: String{
        return "\(i),\(String(describing: d)),\(ki),\(da)"
    }
}

public class Oc:DataBaseObject,CustomStringConvertible{
    @Col(name:"a",primaryKey:true)
    var i:Int = 0
    
    @Col(name:"b")
    var d:Int? = nil
    
    @Col(name:"c")
    var ki:String = ""
    
    @Col(name:"d")
    var da:Data? = nil
    
    public var description: String{
        return "\(i),\(String(describing: d)),\(ki),\(da)"
    }
}
