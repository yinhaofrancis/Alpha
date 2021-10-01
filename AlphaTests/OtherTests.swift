//
//  OtherTests.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/12.
//

import XCTest
@testable import Alpha

class OtherTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    let poor:DataBasePool = try! DataBasePool(name: "mm")
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

    }
    func testFuction(){
        
        poor.write { db in
            let a:JSON = ["a":"dasdasd","b":1,"c":1.3]
            try db.drop(name: "a")
            for i in 0 ..< 10{
                var b:JSON = a;
                b.dddd = i
                b.aaaa = "\(Double(i * i) * 1.1) end"
                b.ddd = Date()
                try db.insert(jsonName: "a", json: b)
            }
        }
        poor.readSync { db in
            struct save {
                var sum:Double
                var count:Int
            }
            db.addFunction(function: Function(name: "cc", nArg: 1, handle: { ctx, c in
                let d:Double = ctx.value(index: 0) + 1.0
                ctx.ret(v: "(\(d))")
            }))
            db.addFunction(function: AggregateFunction(name: "Cou", nArg: 1, step: { ctx, c in
                let c = ctx.aggregateContext(type: save.self)
                c.pointee.count += 1
                c.pointee.sum += ctx.value(index: 0)
            }, final: { ctx in
                let c = ctx.aggregateContext(type: save.self)
                ctx.ret(v: c.pointee.sum / Double(c.pointee.count))
            }))
            try db.exec(sql: "select * , count(*),cc(c),Cou(dddd) as A from a")
            
            let r = try db.query(jsonName: "a")
            for i in r{
                print(i.aaaa)
                print(i.ddd)
            }
        }
    }
    
    func testVTab() throws{
        let poor:DataBasePool = try! DataBasePool(name: "mdm")
        
        poor.write { db in
            let a:JSON = ["a":"dasdasd","b":1,"c":1.3]
            try db.insert(jsonName: "a", json: a)
            try db.exec(sql: "PRAGMA database_list;")
        }
        try poor.loadMode(mode: .WAL)
        measure {
            let wa = XCTestExpectation(description: "dsdd")
            poor.write { db in
                for i in 0 ..< 10000{
                    try db.exec(sql: "insert into a values('asdadsdadasd\(i)')")
                }
            }
            poor.write { db in
                for i in 0 ..< 10000{
                    try db.exec(sql: "insert into a values('asdadsdadasd\(i)')")
                }
            }
            poor.write { db in
                for i in 0 ..< 10000{
                    try db.exec(sql: "insert into a values('asdadsdadasd\(i)')")
                }
            }
            poor.write { db in
                for i in 0 ..< 10000{
                    try db.exec(sql: "insert into a values('asdadsdadasd\(i)')")
                }
            }
            poor.write { db in
                for i in 0 ..< 10000{
                    try db.exec(sql: "insert into a values('asdadsdadasd\(i)')")
                }
            }
            poor.barrier { _ in
                wa.fulfill()
            }
            wait(for: [wa], timeout: TimeInterval.infinity)
        }
    }
//    func testPragame() throws{
//        let db = try Database(url: try! DataBasePool.checkDir().appendingPathComponent("aaaa"))
//        let vm = VModule(name: "aa") { v in
//            return "create table \(v[0])(i,j,a hidden,b hidden)"
//        }
//        vm.isXUpdate = true
//        try vm.loadModule(db: db)
//        try db.exec(sql: "create virtual table if not exists aap using aa(1,2)")
//        try db.exec(sql: "insert into aap values(\(arc4random()),222)")
//        try db.exec(sql: "select * from aap where (i = 10 or j > 100 and i > 1000)")
//        try db.exec(sql: "select * from aap")
//        try db.exec(sql: "select * from aap where i > 100")
//        let json = try db.query(sql: "select * from aap where (i < 10 or j < 0)")
//        while try json.step() {
//            print(json.column(index: 0, type: String.self).value(),
//                  json.column(index: 1, type: String.self).value())
//        }
//        json.close()
//        try db.exec(sql: "update aa set i = 10 where j > 0")
//    }
}

