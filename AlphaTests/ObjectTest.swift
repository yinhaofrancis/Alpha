//
//  HeapTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/17.
//

import XCTest
@testable import Alpha
class ObjectTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testModel() throws{
        let a = a()
        a.string = "dadad"
        a.stringw = "asdadasd"
        a.a = Int(arc4random())
        try a.create(db: self.$aaa)
        try a.insert(db: self.$aaa)
        let pp = try? ObjectRequest<a>(table: "a").query(db: self.$aaa)
        
        print(pp)
        XCTAssert(self.aaa.first?.string == "dadad")
        XCTAssert(self.aaa.first?.stringw == "asdadasd")
        
    }
    @Request(request: ObjectRequest(table: "a"))
    var aaa:[a]
}
class a:Object{
    
    @Col
    var string:String = ""
    
    @NullableCol
    var stringw:String?
    
    @Col([.primary])
    var a:Int = 0
}
class b:Object{
    override var name: String{
        return "a"
    }
    @Col
    var strsdfsdfsi:String = ""
    
    @NullableCol
    var stringw:String?
    
    @Col([.primary])
    var a:Int = 0
}
class c:Object{
    @Col
    var cc:String = ""
    
    @NullableCol
    var bb:String?
    
    @Col
    var aa:Int = 0
    
    @NullableCol
    var fa:a?
}
