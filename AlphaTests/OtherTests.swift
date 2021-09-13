//
//  OtherTests.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/12.
//

import XCTest
@testable import Alpha

class OtherTests: XCTestCase {
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

    }
    func testFuction(){
        
        self.poor.write { db in
            let a:JSON = ["a":"dasdasd","b":1,"c":1.3]
            try db.drop(name: "a")
            for i in 0 ..< 10{
                var b:JSON = a;
                b.dddd = i
                b.aaaa = "\(Double(i * i) * 1.1) end"
                b.ddd = Date()
                try db.insert("a", b)
            }
        }
        self.poor.readSync { db in
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
            
            let r = try db.query(name: "a", conditionString: nil)
            for i in r{
                print(i.aaaa)
                print(i.ddd)
            }
        }
    }
    
    func testVTab(){
        
    }
}

