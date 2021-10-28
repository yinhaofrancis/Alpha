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
        let db = try Database()
        let url = try DataBasePool.checkBackUpDir().appendingPathComponent("bb")
        let backup = try BackupDatabase(url: url, source: db)
        for i in 0 ..< 100{
            try db.save(jsonName: "dsd", json: ["dsds":"sdsds","dds":i])
        }
        let q = try db.query(jsonName: "dsd")
        print(q)
        try backup.backup()
        
    }
}

//public var COMPRESSION_LZ4: compression_algorithm { get } // available starting OS X 10.11, iOS 9.0
//public var COMPRESSION_ZLIB: compression_algorithm { get } // available starting OS X 10.11, iOS 9.0
//public var COMPRESSION_LZMA: compression_algorithm { get } // available starting OS X 10.11, iOS 9.0
//public var COMPRESSION_LZ4_RAW: compression_algorithm { get } // available starting OS X 10.11, iOS 9.0
//public var COMPRESSION_BROTLI: compression_algorithm { get } // available starting OS X 12.0, iOS 15.0
//
///* Apple-specific algorithm */
//public var COMPRESSION_LZFSE: compression_algorithm { get } // available starting OS X 10.11, iOS 9.0

