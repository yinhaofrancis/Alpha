import XCTest
@testable import Dapa

final class DapaTests: XCTestCase {
    func testExample() throws {
        let k = try Database(name: "mm")
        nnn().create(db: k)
        for i in 0 ..< 10{
            var m = nnn()
            m.m = "\(i)"
            m.n = "\(i)000"
            try m.replace(db: k)
        }
        nnn().createIndex(index: "indexMm", withColumn: "n", db: k)
    }
    func testExample11() throws {
        let k = try Database(name: "mm")
        try nnn.update(keyValues: ["n":"@m"]).exec(db: k,param: ["@m":"dada".data(using: .utf8)])

//        print(c)
    }
    
}

@propertyWrapper
public struct DapaPropery<T>{
    public var wrappedValue: T
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

public struct nnn:DatabaseModel{
    public static var tableName: String = "mm"
    
    public static var declare: [Dapa.DatabaseColumeDeclare] {
        [
            DatabaseColumeDeclare(name: "m", type: .textDecType,primary: true),
            DatabaseColumeDeclare(name: "n", type: .doubleDecType)
        ]
    }
    
    public init () {}
    
    public var model: Dictionary<String, Any> = [:]
    
}
