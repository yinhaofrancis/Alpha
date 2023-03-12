import XCTest
@testable import Dapa

final class DapaTests: XCTestCase {
    func testExample() throws {
        let sql = DatabaseGenerator.Select(colume: [
            .alias(name: "mmm.a", alias: "aa"),
            .alias(name: "mmm.b", alias: "bb"),
            .alias(name: "nnn.c", alias: "cc"),
            .alias(name: "nnn.d", alias: "dd")
        ], tableName: .init(table: .name(name: "mmm")).join(type: .leftJoin, table: .name(name: "nnn")), condition: "aa>0", groupBy: ["aa","bb"],orderBy: [
            .init(colume: "aa", asc: true),.init(colume: "bb", asc: false)
        ], limit: 100, offset: 10).sqlCode
        
        print(sql)
        
        let sqq = DatabaseGenerator.Insert(insert: .insert, table: .name(name: "mmm"), colume: [], value: ["1","2"]).sqlCode
        
        let sqqq = DatabaseGenerator.Insert(insert: .replace, table: .name(name: "mmm"), colume: [], value: DatabaseGenerator.Select(tableName: .init(table: .name(name: "mmm")))).sqlCode
        print(sqq)
        print(sqqq)
        
        let sqqqq = DatabaseGenerator.Update(keyValue: ["b": "ii"], table: .name(name: "mmm"), condition: "a == 1").sqlCode
        print(sqqqq)
        
        print(DatabaseGenerator.Delete(table: .name(name: "mmm"), condition: "a == 1").sqlCode)
        
        print(DatabaseGenerator.Index(indexName: .name(name: "imm"), tableName: "mmm", columes: ["a"], condition: "a > 0").sqlCode)
        var m = mmm()
        m["a"] = "k"
        m["b"] = nnn(a: "ll", b: 1)
        var g = m.modelMap
        print(g)
        print(m)
        let a = try! Database(name: "dd")
        a.exec(sql: DatabaseGenerator.Table(tableName: .name(name: mmm.tableName), columeDefine: mmm.declare).sqlCode)
        let tryj = try a.prepare(sql: "select * from mmm")
        try tryj.step()
        var mx = mmm()
        tryj.colume(model: &mx)
        tryj.close()
    }
}

public struct nnn:Codable{
    var a:String
    var b:Int
}

public struct mmm:DatabaseModel{
    public static var tableName: String{
        return "mmm"
    }
    
    public static var declare: [Dapa.DatabaseColumeDeclare]{
        DatabaseColumeTypeDeclare(name: "a", type: .textDecType, keyPath: \mmm.a)
        DatabaseColumeJSONDeclare(name: "b", keyPath: \mmm.b)
    }
    
    public var a:String = ""
    public var b:String = "dasd"
    
}
