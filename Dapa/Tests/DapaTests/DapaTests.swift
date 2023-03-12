import XCTest
@testable import Dapa

final class DapaTests: XCTestCase {
    func testExample() throws {
        let k = try Database(name: "mm")
        nnn().create(db: k)
        for i in 0 ..< 10{
            var m = nnn()
            m.m = "\(i)"
            m.n = "\(i)00"
            try m.insert(db: k)
        }
    }
    func testExample11() throws {
        let k = try Database(name: "mm")
        let n:[nnn] = try DatabaseQueryModel<nnn>(select: .init(tableName: .init(table: .name(name: "mm")),orderBy: [.init(colume: "m", asc: false)],limit: 5,offset: 0)).query(db: k)
        print(n)
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
            DatabaseColumeDeclare(name: "n", type: .textDecType)
        ]
    }
    
    public init () {}
    
    public var model: Dictionary<String, Any> = [:]
    
}
