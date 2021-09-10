//
//  modelTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/31.
//

import XCTest
@testable import Alpha
class modelTest: XCTestCase {

    func datapool(name:String) throws->DataBasePool{
        try DataBasePool(name: name)
    }
    override func setUpWithError() throws {
//        self.db = try self.data(name: "data")
        self.pool = try self.datapool(name: "datapool")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    var pool:DataBasePool!
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        
        
        self.pool.write { db in
            for _ in 0 ..< 10{
                let j:JSON = ["sdada":"dasdasd","cc":3.0,"dd":arc4random() % 100,"dsdsd":["dd","d"],"sad":"dasdasd","k":["a":1]]
                try db.insert("a", j)
            }

        }
        self.pool.writeSync { b in
            var j = try b.query(name: "a")
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
        let aa = a()
        self.pool.writeSync { db in
            try db.drop(name: "c")
            try db.drop(name: "a")
            try db.drop(name: "a_tmp")
            
            let c = c()
            try c.checkObject(db: db)
            c.aa = 1
            c.bb = "bb"
            c.cc = "cc"
            c.fa = a()
            c.fa?.a = 2
            c.fa?.string = "string"
            c.fa?.stringw = "stringw"
            try c.save(db: db)
            
            let a:[c] = try ObjectRequest(table: c.name).query(db: db)
            try a.first?.fa!.queryObject(db: db)
            XCTAssert(a.first!.fa!.a == 2)
            
            XCTAssert(a.first!.bb == "bb")
        }
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
