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
            testa.contentId = i
            testa.name = "\(i)"
            self._ta.add(content: testa)
        }
        print(self.tb)
    }
}

public class testA:DataBaseObject,CustomDebugStringConvertible{
    
    @Col(name:"contentId",primaryKey:true)
    public var contentId:Int = 0
    
    @Col(name:"name")
    public var name:String? = nil
    
    public required init(db: DataBase) throws {
        try super.init(db: db)
        
        try self.createTable(update: DataBaseUpdate {
            
        }, db: db)
    }
    
    required init() {
        super.init()
    }
    
    public var debugDescription: String{
        "\(contentId) | \(String(describing: name))"
    }
}
