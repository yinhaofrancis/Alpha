//
//  DatabaseTest.swift
//  AlphaTests
//
//  Created by hao yin on 2022/4/18.
//

import Foundation
import XCTest
import Alpha




public class DatabaseTest: XCTestCase {
    
    
    func testDataBase() throws{
        let db = try DataBase(name: "dddt", readonly: false, writeLock: false)
        let rs = try db.prepare(sql: "select * from ddd")
        while try rs.step() {
            for i in 0 ..< rs.columeCount{
                print(rs.columeDecType(index: i))
                print(rs.columeInt(index: i))
            }
        }
        db.close()
    }
}
