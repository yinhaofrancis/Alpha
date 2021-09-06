//
//  OtherTests.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/12.
//

import XCTest
@testable import Alpha

class OtherTests: XCTestCase {

    class mk:Model{
        
        
        @objc var a:String = ""
        @objc var b:Int = 0
        @objc var b1:Int8 = 0
        @objc var b2:Int16 = 0
        @objc var b3:Int32 = 0
        @objc var b4:Int64 = 0
        @objc var c:Double = 0.0
        @objc var fc:Float = 0.0
    
        @objc var oa:String?
        @objc var od:Data?
    }
    var poor:DataBasePool = try! DataBasePool(name: "mm")
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCondition() throws{
        let a = (ConditionKey(key: "aa") == ConditionKey(key: "20")) ||
                (ConditionKey(key: "bb") > ConditionKey(key: "20")) &&
                (ConditionKey(key: "cc") < ConditionKey(key: "20")) ||
                (ConditionKey(key: "dd") <> ConditionKey(key: "20")) &&
                Condition.glob(lk: "ee", rk: "10") ||
                Condition.regexp(lk: "ff", rk: "\\S") &&
                Condition.between(lk: "gg", s: "100", e: "200") &&
                Condition.notBetween(lk: "hh", s: "300", e: "400") ||
                Condition.like(lk: "ii", rk: "12312") &&
                Condition.match(lk: "kk", rk: "sdadada") &&
                Condition.exists(lk: "ll", rk: "33434")
        print(a.conditionCode)
        let mkd = mk()
        mkd.setValue("dddd", forKey: "modelId")

    }
    
    func testModel() throws{
        self.poor.write { db in
            try db.create(obj: mk())
        }
        self.poor.writeSync { db in
            
        }
    }
    func testDBQueue() throws{
        self.poor.write { db in
            try db.drop(modelType: mk.self)
            for i in 0 ..< 10 {
                let m = mk()
                m.a = "dadadsa\(i)"
                try SQLResult.save(db: db, model: m)
            }
            
            
        }
        self.poor.writeSync { db in
            let t = try SQLResult.query(db: db, req: FetchRequest<mk>.init(table: mk.self))
//            
//            print(t)
//
            for i in t{
                i.a = "100"
                i.b = 9
                i.c = 0.9
                i.oa = "asada"
                i.od = "dasdasdad".data(using: .utf8)
                try SQLResult.save(db: db, model: i)
            }
            let a = try SQLResult.query(db: db, req: FetchRequest<mk>.init(table: mk.self))
//            print(a)
            for i in a{
                XCTAssert(i.a == "100")
                XCTAssert(i.b == 9)
                XCTAssert(i.c == 0.9)
                XCTAssert(i.oa == "asada")
                XCTAssert(String(data: i.od!, encoding: .utf8) == "dasdasdad")
            }
        }
    }
}
