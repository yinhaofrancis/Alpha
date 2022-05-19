//
//  DatabaseTest.swift
//  AlphaTests
//
//  Created by hao yin on 2022/4/18.
//

import Foundation
import XCTest
import Ammo

public class DatabaseTest: XCTestCase {
    
    
    @DBContent(databaseName: "data")
    var ta:[testA]
    
    
    func testTestA() throws{
        let exp = XCTestExpectation(description: "end")
        let start = Int(Date().timeIntervalSince1970 * 10)
        for i in 0 ..< 10 {
            DispatchQueue.global().async {
                let testa = testA()
                testa.contentId = (start + i)
                testa.name = "\(i) + \(Date())"
                self._ta.add(content: testa)
                if i == 9{
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
                        exp.fulfill()
                    }
                }
            }
        }
        self.wait(for: [exp], timeout: 20000)
    }
}

public class testA:DataBaseObject,CustomDebugStringConvertible{
    
    @Col(name:"contentId",primaryKey:true)
    public var contentId:Int = 0
    
    @Col(name:"name")
    public var name:String? = nil
    
    @Col(name:"display")
    public var display:String? = nil
    
    @Col(name:"display1")
    public var display1:String? = nil
    
    public override var updates: DataBaseUpdate?{
        return DataBaseUpdate {
            DataBaseUpdateCallback(version: 1) { db in
                testA().declare.add(colume: testA()._display1, db: db)
            }
        }
    }
    
    
    public var debugDescription: String{
        "\(contentId) | \(String(describing: name))"
    }
}

public struct testB:DataBaseProtocol,CustomDebugStringConvertible{
    public init() {}
    
    
    @Col(name:"contentId",primaryKey:true)
    public var contentId:Date = Date()
    
    @Col(name:"name")
    public var name:String? = nil
    
    
    
    public init(db: DataBase) throws {
        try testB.createTable(update: self.updates, db: db)
    }
    
    public static var name: String = "testB"
    
    public var updates: DataBaseUpdate?
    
    public var debugDescription: String{
        "\(contentId),\(String(describing: name))"
    }
    
    
}
