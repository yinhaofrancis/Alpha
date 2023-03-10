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
        
        let sqq = DatabaseGenerator.Insert(table: .name(name: "mmm"), colume: [], value: ["1","2"]).sqlCode
        
        let sqqq = DatabaseGenerator.Insert(table: .name(name: "mmm"), colume: [], value: DatabaseGenerator.Select(tableName: .init(table: .name(name: "mmm")))).sqlCode
        print(sqq)
        print(sqqq)
        
        let sqqqq = DatabaseGenerator.Update(keyValue: ["b": "ii"], table: .name(name: "mmm"), condition: "a == 1").sqlCode
        print(sqqqq)
        
        print(DatabaseGenerator.Delete(table: .name(name: "mmm"), condition: "a == 1").sqlCode)
        
        print(DatabaseGenerator.Index(indexName: .name(name: "imm"), tableName: "mmm", columes: ["a"], condition: "a > 0").sqlCode)
    }
}

public class mmm:DatabaseModel{
    public static var tableName: String{
        return "mmm"
    }
    
    public static var declare: [Dapa.DatabaseColumeDeclare]{
        DatabaseColumeDeclare(name: "a", type: .textDecType)
        DatabaseColumeDeclare(name: "b", type: .jsonDecType)
    }
    
    
}
