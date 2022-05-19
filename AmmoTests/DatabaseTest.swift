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
    
    
    @DBContent(name: "data")
    var ta:[testA]
    
    
    @DBContent(name: "data")
    var tb:[testA]
    
    func testTestA() throws{
        
        for i in 0 ..< 10 {
            let testa = testA()
            testa.contentId = Date()
            testa.name = "\(i) + \(Date())"
            self._ta.add(content: testa)
        }
        print(self.tb)
    }
}

public class testA:DataBaseObject,CustomDebugStringConvertible{
    
    @Col(name:"contentId",primaryKey:true)
    public var contentId:Date = Date()
    
    @Col(name:"name")
    public var name:String? = nil
    
    @Col(name:"display")
    public var display:String? = nil
    
    @Col(name:"display1")
    public var display1:String? = nil
    
    public override var updates: DataBaseUpdate?{
        return DataBaseUpdate {
            DataBaseUpdateCallback(version: 1) { i, db in
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
