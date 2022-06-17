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


    
    func testExample() async throws {
        let frame = Item().setChildren(items: [
            Item().config(item: { i in
                i.x = .value(v: 10)
                i.y = .value(v: 10)
                i.width = 20.0
                i.height = 20.0
            }),
            Item().config(item: { i in
                i.x = .value(v: 100)
                i.y = .value(v: 100)
                i.width = 20.0
                i.height = 20.0
            }),
        ])
        frame.layout()
        frame.config { i in
            i.width = 100
            i.height = 100
        }.layout()
        
        XCTAssert(frame.layoutFrame == CGRect(x: 0, y: 0, width: 100, height: 100),"\(frame.layoutFrame)")
    }
   
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
