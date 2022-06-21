//
//  AmmoTests.swift
//  AmmoTests
//
//  Created by hao yin on 2022/4/28.
//

import XCTest
@testable import Ammo
@testable import Data
class AmmoTests: XCTestCase {


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    
    func testExample() throws {
        let s:Stack = Stack(items: [
            Item(width: 10, height: 10, grow: 0, shrink: 0),
            Item(width: nil, height: nil, grow: 1, shrink: 1),
            Item(width: nil, height: nil, grow: 1, shrink: 1),
            Item(width: nil, height: nil, grow: 1, shrink: 1)
        ], width: 100, height: 100, grow: 0, shrink: 0)
        s.align = .fill
        s.relayout()
        print(s)
    }
   
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
