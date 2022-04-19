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
    
    
    func testDataBase() throws{
        let db = try DataBase(name: "dddt", readonly: false, writeLock: false)
        let a = Ob()
        try a.declare.create(db: db)
        a.i = 19
        a.d = nil
        try a.tableModel.insert(db: db)
        a.d = 100
        try a.tableModel.update(db: db)
    }
}
public class Ob:DataBaseObject{
    @Col(name:"dd",primaryKey:true)
    var i:Int = 0
    
    @Col(name:"d")
    var d:Int? = 0
}

