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
    var context = try! Context(name: "pool")
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        
        
        self.context.pool.write { db in
            for _ in 0 ..< 10{
                let j:JSON = ["sdada":"dasdasd","cc":3.0,"dd":arc4random() % 100,"dsdsd":["dd","d"],"sad":"dasdasd","k":["a":1]]
                try db.insert("aaa", j)
            }

        }
        self.context.pool.writeSync { b in
            var j = try b.query(name: "aaa")
            for i in j{
                XCTAssert(i.sdada == "dasdasd")
//                XCTAssert(i.dd == 1)
                XCTAssert(i.dsdsd[1].str() == "d")
                XCTAssert(i.dsdsd[0].str() == "dd")
                XCTAssert(i.sad == "dasdasd")
                XCTAssert(i.k.a == 1)
            }
            for i in 0 ..< j.count{
                var t = j[i]
                t.dd = i
                try b.save("a", t)
            }
            j = try b.query(name: "a")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testObject() throws{
        self.context.pool.writeSync { db in
            try db.drop(name: "c")
            try db.drop(name: "a")
            try db.drop(name: "a_tmp")
            
        }
        let c = self.context.create(type: c.self)
        
        c.aa = 1
        c.bb = "bb"
        c.cc = "cc"
        c.fa = self.context.create(type: a.self)
        c.fa?.a = 2
        c.fa?.string = "string"
        c.fa?.stringw = "stringw"
        self.context.save(objct: c)
        let request = ObjectRequest<c>(table: c.name)
        let a = self.context.request(request: request)
        
//            try c.save(db: db)
//
//            let a:[c] = try .query(db: db)
//            try a.first?.fa!.queryObject(db: db)
        XCTAssert(a.first!.fa!.a == 2)

        XCTAssert(a.first!.bb == "bb")
//        }
    }
    func testreflect() throws{
        let aa = c()
        let a = aa.keyCol
        print(aa.createCode)
    }
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
