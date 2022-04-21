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
        let db = try DataBase(name: "dddt")
        let a = Ob()
        try a.declare.create(db: db)
        
        for i in 0 ..< 80 {
            a.i = i
            a.d = nil
            a.ki = "dadada王🉑️"
            a.da = "dadada王🉑️".data(using: .utf8)
            try a.tableModel.insert(db: db)
            a.d = 100
            try a.tableModel.update(db: db)
        }
        let mm = a.tableModel
        mm.declare[0].origin = 1
        mm.declare[1].origin = 2
        a.tableModel = mm
        a.d = 99999
        a.i = 19
        
        try mm.select(db: db)
        
//        a.tableModel = mm
        print(a.ki)
        db.close()
        
        
    }
    func testbkDataBase() throws {
        let db = try DataBase(name: "dddt")
        let bdb = try BackUpDataBase(name: "ddtb", database: db);
        try bdb.backup()
        db.close()
        db.deleteDatabaseFile()
        
    }
    func testrsDataBase() throws {
        let rsd = try RestoreDataBase(name: "dddt", backup: "ddtb")
        try rsd.restore()
    }
    
}
public class Ob:DataBaseObject{
    @Col(name:"dd",primaryKey:true)
    var i:Int = 0
    
    @Col(name:"d")
    var d:Int? = nil
    
    @Col(name:"k")
    var ki:String = ""
    
    @Col(name:"pipe")
    var da:Data? = nil
}

