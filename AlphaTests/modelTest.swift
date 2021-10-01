//
//  modelTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/31.
//

import XCTest
@testable import Alpha
class modelTest: XCTestCase {

    override func setUpWithError() throws {

    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    let context = try! Context(name: "pool")
    func testExample() throws {
        
        context.pool.write { b in
            try b.drop(name: "a")
        }
        try context.pool.loadMode(mode: .ACP)
        measure {
            runR()
        }
        
    }
    func runR(){
        let wa = XCTestExpectation(description: "dsdd")
        for i in 0 ..< 10{
            context.pool.write { db in
                for _ in 0 ..< 10{
                    let j:JSON = ["sdada":"dasdasd","cc":3.0,"dd":arc4random() % 100,"dsdsd":["dd","d"],"sad":"dasdasd","k":["a":1]]
                    try db.insert(jsonName: "aaa", json: j)
                }
                try a().create(db: db)
                for i in 0 ..< 10{
                    let aa = a()
                    aa.string = "\(i)"
                    aa.stringw = "\(i + 11)"
                    aa.a = i
                    try aa.save(db: db)
                }
            }
            context.pool.read { db in
                let pp = try a().queryModel(db: db, type: a.self)
                print(pp)
            }
            context.pool.write { db in
                for _ in 0 ..< 10{
                    let j:JSON = ["sdada":"dasdasd","cc":3.0,"dd":arc4random() % 100,"dsdsd":["dd","d"],"sad":"dasdasd","k":["a":1]]
                    try db.insert(jsonName: "aaa", json: j)
                }
                try a().create(db: db)
                for i in 0 ..< 10{
                    let aa = a()
                    aa.string = "\(i)"
                    aa.stringw = "\(i + 11)"
                    aa.a = i
                    try aa.save(db: db)
                }
            }
            context.pool.read { db in
                let pp = try a().queryModel(db: db, type: a.self)
                print(pp)
            }
        }
        context.pool.barrier { db in
            wa.fulfill()
        }
        wait(for: [wa], timeout: 100)
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testObject() throws{
        context.pool.writeSync { db in
            try db.drop(name: "c")
            try db.drop(name: "a")
            try db.drop(name: "a_tmp")
            
        }
        let c = context.create(type: c.self)
        
        c.aa = 1
        c.bb = "bb"
        c.cc = "cc"
        c.fa = context.create(type: a.self)
        c.fa?.a = 2
        c.fa?.string = "string"
        c.fa?.stringw = "stringw"
        context.save(objct: c)
        let request = ObjectRequest<c>(table: c.name)
        let a = context.request(request: request)
        XCTAssert(a.first!.fa!.a == 2)
        XCTAssert(a.first!.bb == "bb")
    }
    func testreflect() throws{
        let b = UnsafeMutablePointer<B>.allocate(capacity: 1)
        var bb = B(a: A(index: 1, n: 2.9), mm: "MM")
        memcpy(b, &bb, MemoryLayout<B>.size)
        let p = unsafeBitCast(b, to: UnsafeMutablePointer<A>.self)
        pp(p: p)
    }
    public func pp(p:UnsafeMutablePointer<A>){
        XCTAssert(p.pointee.index == 1)
        XCTAssert(p.pointee.n == 2.9)
    }
    
    public func testVT() throws{
//        try vt.loadModule(db: db)
//        try db.exec(sql: "PRAGMA table_info(ak)")
        let db = try Database()
        let json:JSON = ["dsds":"asdasd","a":["dd":"ddddd"]]
        try db.insert(jsonName: "a", json: json)
        try db.exec(sql: "select * from a")
        
        let a = try db.query(jsonName: "a")
        XCTAssert(a.first?.dsds.str() == "asdasd")
        XCTAssert(a.first?.a.dd.str() == "ddddd")
        var aa = a.first
        aa?.dsds = "aaa"
        try db.save(jsonName: "a", json: aa!)
        let ar = try db.query(jsonName: "a")
        XCTAssert(ar.count == 1)
        XCTAssert(ar.first?.dsds.str() == "aaa")
        let r = try db.query(jsonName: "a", condition: ConditionKey.jsonConditionKey(key: "$.a.dd") == "?", values: ["ddddd"])
        XCTAssert(r.count == 1)
        XCTAssert(r.first?.dsds.str() == "aaa")
        try db.update(jsonName: "a", current: r.first!, patch: json)
        
        let rr = try db.query(jsonName: "a", condition: ConditionKey.jsonConditionKey(key: "$.a.dd") == "?", values: ["ddddd"])
        XCTAssert(rr.count == 1)
        XCTAssert(rr.first?.dsds.str() == "asdasd")
        
        
        let patch:JSON = ["pp":"pp"]
        try db.update(jsonName: "a", current: rr.first!, patch: patch)
        let rrr = try db.query(jsonName: "a", condition: ConditionKey.jsonConditionKey(key: "$.a.dd") == "?", values: ["ddddd"])
        print(rrr)
        XCTAssert(rrr.count == 1)
        XCTAssert(rrr.first?.pp.str() == "pp")
        
        try db.delete(jsonName: "a", current: rrr.first!)
        XCTAssert(try db.query(jsonName: "a", condition: ConditionKey.jsonConditionKey(key: "$.a.dd") == "?", values: ["ddddd"]).count == 0)
    }
}
struct A {
    var index:Int
    var n:Double
}
struct B {
    var a:A
    var mm:String
}

class a:Object{
    
    @Col
    var string:String = ""
    
    @NullableCol
    var stringw:String?
    
    @Col([.primary])
    var a:Int = 0
}
class b:Object{
    override var name: String{
        return "a"
    }
    @Col
    var strsdfsdfsi:String = ""
    
    @NullableCol
    var stringw:String?
    
    @Col([.primary])
    var a:Int = 0
}
class c:Object{
    @Col
    var cc:String = ""
    
    @NullableCol
    var bb:String?
    
    @Col
    var aa:Int = 0
    
    @NullableCol
    var fa:a?
}
