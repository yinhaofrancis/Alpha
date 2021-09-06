//
//  AlphaTests.swift
//  AlphaTests
//
//  Created by hao yin on 2021/7/27.
//

import XCTest
@testable import Alpha

class AlphaTests: XCTestCase {

    struct model:SQLCode{
        static var tableName: String = "model"
        
        @PrimaryKey
        @Column(\model.a)
        var a:Int = 0
        
        @Key("b_key")
        @Unique
        @Column(\model.b)
        var b:String = ""
        
        @Column(\model.c)
        var c:Data = Data()
        
        @Default("3.14")
        @Column(\model.d)
        var d:Double = 0.0
        
        @Column(\model.f)
        var f:Int32 = 0
        
        @Column(\model.g)
        var g:Int64 = 0
        
    
        @NullableColumn(\model.oa)
        var oa:Int? = nil
        
        @Key("ob_key")
        @NullableColumn(\model.ob)
        var ob:String? = nil
        
        @NullableColumn(\model.oc)
        var oc:Data? = nil
        
        @NullableColumn(\model.od)
        var od:Double? = nil

        @NullableColumn(\model.of)
        var of:Int32? = 0
        
        @NullableColumn(\model.og)
        var og:Int64? = 1
    }
    struct model2:SQLCode{
        static var tableName: String = "model2"
        
        @PrimaryKey
        @Key("Identify")
        @Column(\model2.a2)
        var a2:Int = 0
        
        
        @ForeignKey(remoteTable: "model", remoteKey: "a", onDelete: .SET_DEFAULT, onUpdate: .CASCADE)
        @Default("0")
        @Key("IdentifyRef")
        @Column(\model2.a)
        var a:Int = 0
        
        @ForeignKey(remoteTable: "model", remoteKey: "b_key", onDelete: .NO_ACTION, onUpdate: .NO_ACTION)
        @Column(\model2.b)
        var b:String = ""
        
    }
    func data(name:String)throws ->Database{
        try Database(url: Env.home().appendingPathComponent(name))
    }
    func datapool(name:String) throws->DataBasePool{
        try DataBasePool(name: name)
    }
    override func setUpWithError() throws {
//        self.db = try self.data(name: "data")
        self.pool = try self.datapool(name: "datapool")
//        try self.pool.loadMode(mode: .ACP)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        print(self.pool.url)
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
//    var db:Database!
    var pool:DataBasePool!

    func testCreateAndDropTable() throws {

        self.pool.writeSync { db in
            let sql = """
            CREATE TABLE pp (
                Field1 INTEGER,
                Field2 TEXT UNIQUE,
                Field3    BLOB NOT NULL DEFAULT k,
                PRIMARY KEY(Field1 AUTOINCREMENT)
                );
                CREATE TABLE sds (
                    Field1    INTEGER,
                    Field2    TEXT DEFAULT d UNIQUE COLLATE BINARY,
                    FOREIGN KEY(Field2) REFERENCES pp(Field1) on delete cascade,
                    PRIMARY KEY(Field2)
                );
    """
            try db.exec(sql: sql)
            let pp = try db.tableInfo(name: "pp")
            for i in pp {
                if i.key == "Field1"{
                    XCTAssert(i.value.cid == 0, "index fail")
                    XCTAssert(i.value.name == "Field1", "name fail")
                    XCTAssert(i.value.type == "INTEGER", "type fail")
                    XCTAssert(i.value.dlft_value == "", "default fail")
                    XCTAssert(i.value.pk == 1, "default fail")
                    XCTAssert(i.value.notnull == 0, "default fail")
                }
                if i.key == "Field2"{
                    XCTAssert(i.value.cid == 1, "index fail")
                    XCTAssert(i.value.name == "Field2", "name fail")
                    XCTAssert(i.value.type == "TEXT", "type fail")
                    XCTAssert(i.value.dlft_value == "", "default fail")
                    XCTAssert(i.value.pk == 0, "default fail")
                    XCTAssert(i.value.notnull == 0, "default fail")
                }
                if i.key == "Field3"{
                    XCTAssert(i.value.cid == 2, "index fail")
                    XCTAssert(i.value.name == "Field3", "name fail")
                    XCTAssert(i.value.type == "BLOB", "type fail")
                    XCTAssert(i.value.dlft_value == "k", "default fail")
                    XCTAssert(i.value.pk == 0, "default fail")
                    XCTAssert(i.value.notnull == 1, "default fail")
                }
            }
            let fp = try db.tableForeignKeyInfo(name: "sds")
            for i in fp{
                XCTAssert(i.key == "Field2", "name fail")
                XCTAssert(i.value.id == 0 , "name fail")
                XCTAssert(i.value.from == "Field2", "from fail")
                XCTAssert(i.value.to == "Field1", "to fail")
                XCTAssert(i.value.table == "pp", "ref table fail")
                XCTAssert(i.value.onUpdate == .NO_ACTION, "name fail")
                XCTAssert(i.value.onDelete == .CASCADE, "name fail")
            }
            try db.renameColumn(name: "pp", columeName: "Field1", newName: "F11")
            try db.addColumn(name: "pp", columeName: "F12", type: Int.self, notnull: true , defaultValue: "d")
            try db.addColumn(name: "pp", columeName: "F13", type: String.self)
            let renameresult = try db.tableInfo(name: "pp").contains { v in
                v.key == "F11"
            }
            let renameresult2 = try db.tableInfo(name: "pp").contains { v in
                v.key == "F12"
            }
            let renameresult3 = try db.tableInfo(name: "pp").contains { v in
                v.key == "F13"
            }
            XCTAssert(try db.tableExists(name: "pp"))
            XCTAssert(renameresult)
            XCTAssert(renameresult2)
            XCTAssert(renameresult3)
        }
    }
    func testCreateTableByModel() throws {
        self.pool.config { db in
            db.foreignKey = true
        }
        self.pool.write { db in
            struct model3:SQLCode{
                static var tableName: String =  "model3"
                
            
                
                var i:Int = 0
            }
            try db.drop(modelType: model2.self)
            try db.drop(modelType: model.self)
            try db.drop(modelType: model3.self)
            try db.create(obj: model())
            try db.create(obj: model2())
            try db.create(obj: model3())
            for i in 0 ..< 10 {
                try db.insert(model: model(a: i,
                                           b: "ddd\(i)",
                                           c: "dd\(i * 2)".data(using: .utf8)!
                                           , d: 0.9 + Double(i),oa: i + 1,of: 10 - Int32(i)))
            }
            for i in 0 ..< 10 {
                do {
                    try db.insert(model: model(a: i, b: "ddd", c: "dd".data(using: .utf8)!, d: 0.9))
                } catch {
                    break;
                }
                XCTAssert(false, "table primary constaint fail")
            }
            for i in 0 ..< 10 {
                try db.insert(model: model2(a2: i, a: i,b: "ddd\(i)"))
            }
            var f = false
            do {
                try db.insert(model: model2(a2: 10000, a:10000))
            } catch  {
                f = true
            }
            
            XCTAssert(f, "table foreign keu constaint fail")
            let r = try db.select(request: FetchRequest(table: model.self))
            print(r)
            for i in 0..<10 {
                XCTAssert(r[i].a == i,"\(r[i].a)")
                XCTAssert(r[i].b == "ddd\(i)",r[i].b)
                XCTAssert(String(data: r[i].c, encoding: .utf8)! == "dd\(i * 2)",String(data: r[i].c, encoding: .utf8)!)
                XCTAssert(r[i].d == 0.9 + Double(i),"\(r[i].d )")
                XCTAssert(r[i].f == 0)
                XCTAssert(r[i].g == 0)
                XCTAssert(r[i].oa == i + 1)
                XCTAssert(r[i].ob == nil)
                XCTAssert(r[i].oc == nil)
                XCTAssert(r[i].od == nil)
                XCTAssert(r[i].of! == 10 - i)
                XCTAssert(r[i].og == 1)
            }
            let r2 = try db.select(request: FetchRequest(table: model2.self))
            for i in 0..<10 {
                XCTAssert(r2[i].a == i)
                XCTAssert(r2[i].a2 == i)
            }
            var up = r[0]
            up.og = nil
            up.oc = "abc".data(using: .utf8)
            up.ob = "abc"
            try db.update(model: up)
            let rr = try db.select(model: model(a: 0))
            XCTAssert(rr != nil)
            XCTAssert(rr?.og == nil)
            
            XCTAssert(String(data: rr!.oc!, encoding: .utf8)! == "abc")
            XCTAssert(rr?.ob == "abc")
        }
        self.pool.writeSync { db in

        }
    }
    func testSelect() throws{
        self.pool.write { db in
            try db.drop(modelType: model2.self)
            try db.drop(modelType: model.self)
            try db.create(obj: model())
            try db.create(obj: model2())
            for i in 0 ..< 100 {
                try db.insert(model: model(a: i,
                                           b: "ddd\(i)",
                                           c: "dd\(i * 2)".data(using: .utf8)!
                                           , d: 0.9 + Double(i),oa: i + 1,of: 10 - Int32(i)))
            }
            let request = FetchRequest(table: model.self, condition: ConditionKey("a") < "@ktop" && ConditionKey("a") > "@kbottom", page: Page(offset: 10, limit: 20), order: [.desc("a")])
            request.loadKeyMap(map: ["kbottom":"10","ktop":"90"])
            let r = try db.select(request: request)
            for i in 0 ..< r.count {
                XCTAssert(r[i].a == 79 - i)
            }
            var noExist = r[0]
            noExist.a = -1000
            XCTAssert(try db.exists(model: r[0]))
            XCTAssert(try !db.exists(model: noExist))
            XCTAssert(try db.count(model: model.self) == 100)
            XCTAssert(try db.select(type: model.self, key: .max("a"))?.b == "ddd99")
            XCTAssert(try db.select(type: model.self, key: .min("a"))?.b == "ddd0")
            try db.delete(model: r[0])
            XCTAssertNil(try db.select(model: r[0]))
            try db.delete(table: model.self, condition: Condition.like(lk: "b_key", rk: "@linl"), bind: ["linl":"ddd1%"])
            let cc = try db.count(model: model.self)
            XCTAssert(cc == 88)
            try db.update(model: ["c":"sdsds".data(using: .utf8)!], table: model.self, condition: Condition.like(lk: "b_key", rk: "@linl"), bind: ["linl":"ddd2%"])
            let datas = try db.select(request: FetchRequest(table: model.self, key: .all, condition: Condition.like(lk: "b_key", rk: "@linl")).loadKeyMap(map: ["linl":"ddd2%"]))
            for i in datas {
                XCTAssert("sdsds" == String(data: i.c, encoding: .utf8))
            }
            try db.dataMaster(type: "table").map({$0.name}).forEach { i in
                print(try db.integrityCheck(table: i))
            }
            noExist.b = "dsdsadasdasdasdadadas"
            try db.save(model: noExist)
            for i in try db.select(request: FetchRequest(table: model.self, key: .all, condition: ConditionKey("a") == "@a1").loadKeyMap(map: ["a1":noExist.a])){
                if i.a == noExist.a{
                    XCTAssert(i.b == noExist.b)
                }
            }
            noExist.b = "dddddfdfdfdfdfdfdfdsdsdsds"
            try db.save(model: noExist)
            for i in try db.select(request: FetchRequest(table: model.self, key: .all, condition: ConditionKey("a") == "@a1").loadKeyMap(map: ["a1":noExist.a])){
                if i.a == noExist.a{
                    XCTAssert(i.b == noExist.b)
                }
            }
        }
        self.pool.writeSync { db in
   
        }
    }
    func testRollback() throws {
        
        self.pool.write { db in
            
            try db.drop(modelType: model2.self)
            try db.drop(modelType: model.self)
            try db.create(obj: model())
            try db.create(obj: model2())
            for i in 0 ..< 100 {
                try db.insert(model: model(a: i,
                                           b: "ddd\(i)",
                                           c: "dd\(i * 2)".data(using: .utf8)!
                                           , d: 0.9 + Double(i),oa: i + 1,of: 10 - Int32(i)))
            }
            try db.exec(sql: "PRAGMA journal_mode")
        }
        self.pool.write { db in
            for i in 0..<100{
                try db.update(model: ["oa":100 + i], table: model.self, condition: ConditionKey(key: "a") == ConditionKey(key: "\(i)"))
            }
            try db.exec(sql: "PRAGMA journal_mode")
            throw NSError(domain: "e", code: 0, userInfo: nil)
        }

        self.pool.read { db in
            let m = model(a:0)
            let new = try db.select(model: m)
            XCTAssert(new?.oa == 1)
            print(db.url)
            try db.exec(sql: "PRAGMA journal_mode")
        }
        self.pool.writeSync { db in
            
        }
    }
    func testAlterTable() throws {
        
        self.pool.write { db in
            try db.drop(modelType: model2.self)
            try db.drop(modelType: model.self)
            try db.create(obj: model())
            try db.create(obj: model2())
            
            for i in 0 ..< 100 {
                try db.insert(model: model(a: i,
                                           b: "ddd\(i)",
                                           c: "dd\(i * 2)".data(using: .utf8)!
                                           , d: 0.9 + Double(i),oa: i + 1,of: 10 - Int32(i)))
            }
            
            for i in 0 ..< 100 {
                try db.insert(model: model2(a2: i, a: i,b: "ddd\(i)"))
            }
            struct model0:SQLCode{
                static var tableName: String = "model"
                
                @PrimaryKey
                @Column(\model.a)
                var a:Int = 0
            }
            struct model3:SQLCode{
                static var tableName: String = "model2"
                
                @PrimaryKey
                @Key("Identify")
                @Column(\model3.a2)
                var a2:Int = 0
                
                
                @ForeignKey(remoteTable: "model", remoteKey: "a", onDelete: .SET_DEFAULT, onUpdate: .CASCADE)
                @Default("0")
                @Key("IdentifyRef")
                @Column(\model3.a)
                var a:Int = 0
                
                @Default("null")
                @Column(\model3.m)
                var m:String = ""
                
                
                @NullableColumn(\model3.n)
                var n:String? = ""
                
                @ForeignKey(remoteTable: "model", remoteKey: "b_key", onDelete: .NO_ACTION, onUpdate: .NO_ACTION)
                @Column(\model3.b)
                var b:String = ""
                
            }
            
            
            struct model4:SQLCode{
                static var tableName: String = "model2"
                
                @PrimaryKey
                @Key("Identify")
                @Column(\model4.a2)
                var a2:Int = 0
            }
            try db.create(obj: model3())
            let renameresult = try db.tableInfo(name: "model2").contains { v in
                v.key == "m"
            }
            let renameresult2 = try db.tableInfo(name: "model2").contains { v in
                v.key == "n"
            }
            XCTAssert(renameresult)
            XCTAssert(renameresult2)
            
            try db.create(obj: model4())
            try db.create(obj: model0())
            let renameresult3 = try db.tableInfo(name: "model").contains { v in
                v.key != "m" && v.key != "m" && v.key != "dentifyRef" && v.key != "b"
            }
            XCTAssert(renameresult3)
    
        }

        self.pool.writeSync { db in
            
        }
    }
    func testVersion() throws{
        self.pool.write { db in
            let version = db.version + 1
            try db.setVersion(version: version)
            XCTAssert(version == db.version)
            print("_+_+_+_+_+_")
            print(version,db.version)
        }
        self.pool.writeSync { db in
            
        }
    }
}
public class Env{
    public static func home()throws->URL{
        guard let u = URL(string: NSHomeDirectory()) else { throw NSError(domain: "no home", code: 0, userInfo: nil) }
        return u
    }
}
