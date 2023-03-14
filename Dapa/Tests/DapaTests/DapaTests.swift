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
            m.json = ["dsds":"asdada"]
            m.date = Date()
            try m.replace(db: k)
        }
        nnn().createIndex(index: "indexMm", withColumn: "n", db: k)
        
        
        nm().create(db: k)
        for i in 0 ..< 10{
            var m = nm()
            m.name = "dadad"
            m.age = i
            try m.replace(db: k)
        }
        nm().createIndex(index: "indexMmd", withColumn: "name", db: k)
    }
    func testExample11() throws {
        print(nm.declare.map({$0.name}))
        let k = try Database(name: "mm")
        let a:[DatabaseResultModel] = try nnn.select().query(db: k)
        try nnn.update(keyValues: ["n":"@m"]).exec(db: k,param: ["@m":"dada".data(using: .utf8)])
        let b:[nm] = try nm.select().query(db: k)
        print(a)
        print(b.map({ nm in
            nm.model
        }))
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
    public static var tableName: String = "mmu"
    
    public static var declare: [Dapa.DatabaseColumeDeclare] {
        [
            DatabaseColumeDeclare(name: "m", type: .textDecType,primary: true),
            DatabaseColumeDeclare(name: "n", type: .doubleDecType),
            DatabaseColumeDeclare(name: "json", type: .jsonDecType),
            DatabaseColumeDeclare(name: "date", type: .dateDecType)
        ]
    }
    
    public init () {}
    
    public var model: Dictionary<String, Any> = [:]
    
}

public struct nm:DatabaseWrapModel{
    public static var tableName: String{
        return "nm"
    }
    public init() {}
    
    @DapaColume(type: .textDecType)
    public var name:String = ""
    
    @DapaColume(type: .intDecType,primary: true)
    public var age:Int = 0
    
}
