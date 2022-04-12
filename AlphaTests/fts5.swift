//
//  fts5.swift
//  AlphaTests
//
//  Created by wenyang on 2021/10/10.
//

import XCTest

@testable import Alpha
class fts5: XCTestCase {

    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let db = try DB()
        let url = try Pool.checkBackUpDir().appendingPathComponent("bb")
        let backup = try BackupDatabase(url: url, source: db)
        for i in 0 ..< 100{
            try db.save(jsonName: "dsd", json: ["dsds":"sdsds","dds":i])
        }
        let q = try db.query(jsonName: "dsd")
        print(q)
        try backup.backup()
    }
}



