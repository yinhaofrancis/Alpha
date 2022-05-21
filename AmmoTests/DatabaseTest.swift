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
    
    @DBContent(databaseName: "data")
    var tb:[testB]
    
    @DBFetchContent(databaseName: "data", fetch: testAB.fetch(table: testA.self).joinQuery(join: .join, table: testB.self).whereCondition(condition: QueryCondition.Key(key: "contentId", table: testA.self) == QueryCondition.Key(key: "contentId", table: testB.self)))
    var tab:[testAB]
    
    @DBFetchContent(databaseName: "data", fetch:testAB.fetch(table: testA.self).joinQuery(join: .join, table: testB.self).whereCondition(condition: QueryCondition.Key(key: "contentId",table:testA.self) == QueryCondition.Key(key: "@id") &&  QueryCondition.Key(key: "contentId",table:testB.self) == QueryCondition.Key(key: "@id2")),param:["@id":16531432022,"@id2":16531432022])
    var tab2:[testAB]
    
    @DBFetchView(view: testabv(), name: "data")
    var tab3:[testAB]
    
    @DBWorkFlow(name: "data")
    var work:DataBaseWorkFlow
    
    func testTestA() throws{
        let exp = XCTestExpectation(description: "end")
        let start = Int(Date().timeIntervalSince1970 * 10)
        for i in 0 ..< 10 {
            DispatchQueue.global().async {
                let testa = testA()
                testa.contentId = (start + i)
                testa.name = "\(i) + \(Date())"
                self._ta.add(content: testa)
                let testb = testB()
                testb.contentId = (start + i)
                testb.name = "\(start + i)"
                self._tb.add(content: testb)
                
                if i == 9{
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
                        exp.fulfill()
                    }
                }
            }
        }
        
        self.wait(for: [exp], timeout: 20000)
    }
    public func testABr() throws{
        print(tab2)

    }
    public func testABVr() throws{
        let t = testabv()
        self.work.syncWorkflow { db in
            try t.createView(db: db)
        }
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
    public var contentId:Int = 0
    
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

public class testAB:DataBaseFetchObject,CustomDebugStringConvertible{
    public var debugDescription: String{
        return "\(contentAId)|\(String(describing: contentAName))|\(contentBId)|\(String(describing: contentBName))"
    }
    
    
    @QueryColume(colume: "contentId", type: testA.self)
    public var contentAId:Int = 0
    
    @QueryColume(colume: "name", type: testA.self)
    public var contentAName:String? = nil
    
    @QueryColume(colume: "contentId", type: testB.self)
    public var contentBId:Int = 0
    
    @QueryColume(colume: "name", type: testB.self)
    public var contentBName:String? = nil
    
}


public struct testabv:DataBaseFetchViewProtocol{
    
    public typealias Objects = testAB
    
    public var fetch: DataBaseFetchObject.Fetch{
        testAB.fetch(table: testA.self).joinQuery(join: .join, table: testB.self).whereCondition(condition: QueryCondition.Key(key: "contentId", table: testA.self) == QueryCondition.Key(key: "contentId", table: testB.self))
    }
    
    public var name: String{
        "testABV"
    }
}
