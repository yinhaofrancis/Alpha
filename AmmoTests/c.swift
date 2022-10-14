//
//  c.swift
//  AmmoTests
//
//  Created by wenyang on 2022/10/14.
//

import XCTest
import Ammo
@testable import RenderImage
class c: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let a = imageDataCache()
        let cg = UIImage(named: "p.png")
        var array:[CGImage] = []
        
        self.measure {
            for i in 0 ..< 1000{
                array.append(cg!.cgImage!)
            }
            for i in 0 ..< 1000{
                a.store(key: "\(i)", data: array[i])
            }
            for i in 0 ..< 1000{
                array.removeAll()
            }
        }
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
