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
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

public struct aa:ModuleEntry{
    public var memory: Memory = .Singleton
    
    public var name: String = "dsdsds"
    
}

public struct mm:Module{
    var i:Int = 100
    public var entries: [String : ModuleEntry]{
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
        aa(memory: .Normal, name: "q")
    }
}
