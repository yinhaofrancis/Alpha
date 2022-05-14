//
//  AmmoTests.swift
//  AmmoTests
//
//  Created by hao yin on 2022/4/28.
//

import XCTest
@testable import Ammo
class AmmoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let bucket = ModuleBucket {
            mm(name: "aa", i: 10)
            mm(name: "bb", i: 10)
            mm(name: "cc", i: 10)
            mm(name: "dd",memory: .Singleton, i: 10)
        }
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "dd")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "aa")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "aa")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "aa")?.call(event: .c)?.call(param: nil)
        bucket.module(name: "aa")?.call(event: .c)?.call(param: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
extension EventKey{
    public static var a:EventKey = EventKey(rawValue: "a")
    public static var b:EventKey = EventKey(rawValue: "b")
    public static var c:EventKey = EventKey(rawValue: "c")
}

public struct mm:Module{
    public var name: String = "aaa"
    
    public var memory: Memory = .Normal
    
    @ModuleState
    var i:Int = 10
    var j:Int = 10
    public var entries: [String : ModuleEntry]{
        ClosureEntry(name: .a) { param in
            print(param as Any)
        }
        ClosureEntry(name: .b) { param in
            print(param as Any)
        }
        ClosureEntry(name: .c) { param in
            self.i += self.j
            print(self.i)
        }
    }
    public init(name:String,memory:Memory = .Normal,i:Int){
        self.name = name
        self.memory = memory
        self.i = i
    }
}
