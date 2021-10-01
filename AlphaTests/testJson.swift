//
//  testJson.swift
//  AlphaTests
//
//  Created by hao yin on 2021/9/28.
//

import XCTest
import Alpha

class testJson: XCTestCase {

    let pool = try! DataBasePool(name: "json")
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJsonSave() throws {
        let json:JSON = ["sds":1,"a":2,"b":"true","p":["a",["c","d"],"b"],"q":["cc":1.9,"aa":"a"]]
        self.pool.writeSync { db in
            try db.save(jsonName: "test", json: json)
            let a = try db.query(jsonName: "test", condition: ConditionKey.jsonConditionKey(key: "$.sds") == 1, values: [])
            XCTAssert(a.count == 1)
            XCTAssert(a[0].sds == 1)
            XCTAssert(a[0].a == 2)
            XCTAssert(a[0].b == true)
            XCTAssert(a[0].p[0] == "a")
            XCTAssert(a[0].q.cc == 1.9)
            var jj = a[0]
            jj.a = 4
            jj.b = false
            jj.p[0] = "aaaa";
            try db.save(jsonName: "test", json: jj)
            let b = try db.query(jsonName: "test", condition: ConditionKey.jsonConditionKey(key: "$.sds") == 1, values: [])
            XCTAssert(b.count == 1)
            XCTAssert(b[0].sds == 1)
            XCTAssert(b[0].a == 4)
            XCTAssert(b[0].b == false)
            XCTAssert(b[0].p[0] == "aaaa")
            XCTAssert(b[0].q.cc == 1.9)
            try db.delete(jsonName: "test", current: jj)
            try db.insert(jsonName: "test", json: jj, patch: ["qq":"qq"])
            let nue = try db.query(jsonName: "test", condition: ConditionKey.jsonConditionKey(key: "$.sds") == 1, values: [])
            XCTAssert(nue[0].qq == "qq")
            XCTAssert(nue.count == 1)
            XCTAssert(nue[0].sds == 1)
            XCTAssert(nue[0].a == 4)
            XCTAssert(nue[0].b == false)
            XCTAssert(nue[0].p[0] == "aaaa")
            XCTAssert(nue[0].q.cc == 1.9)
            try db.drop(name: "test")
            try db.insert(jsonName: "test", json: jj, patch: ["qq":"qq"])
            try db.drop(name: "test")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
