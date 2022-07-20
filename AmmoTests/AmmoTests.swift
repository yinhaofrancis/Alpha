//
//  AmmoTests.swift
//  AmmoTests
//
//  Created by hao yin on 2022/4/28.
//

import XCTest
@testable import Ammo
@testable import Data
import JavaScriptCore
class AmmoTests: XCTestCase {


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testFF(){
        let m = XCTestExpectation(description: "mark")
        let m2 = XCTestExpectation(description: "mark2")
        StaticStringDownloader.shared.downloadImage(url: URL(string: "https://app.5eplay.com/api/csgo/tournament/game_session_info/65456")!) { string in
            print(string)
            m.fulfill()
            
        }
        StaticJSONDownloader.shared.downloadImage(url: URL(string: "https://app.5eplay.com/api/csgo/tournament/game_session_info/65456")!) { string in
            print(string)
            m2.fulfill()
            
        }
        self.wait(for: [m,m2], timeout: 10)
    }
    
    
    func testExample() throws {
  
        let ns:[Node] = (0 ..< 5).map { _ in
            createNode()
        }
        let a = Node()
        a.width = Value(constant: 1000, mode: .absoluteValue)
        a.height = Value(constant: 1000, mode: .absoluteValue)
        a.children = ns
        a.layout()
        print(a)
    }
   
    func createNode()->Node{
        let ns:[Node] = (0 ..< 5).map { _ in
            let n = Node()
            n.width = Value(constant: 10, mode: .absoluteValue)
            n.height = Value(constant: 10, mode: .absoluteValue)
            return n
        }
        let a = Node()
        a.children = ns
        return a
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
