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
            m.fulfill()
        }
        StaticJSONDownloader.shared.downloadImage(url: URL(string: "https://app.5eplay.com/api/csgo/tournament/game_session_info/65456")!) { string in
            m2.fulfill()
        }
        self.wait(for: [m,m2], timeout: 10)
    }
    
    
//    func testExample() throws {
//        let data = DataSortSet<Int>()
//        
//        for i in 0 ..< 10{
//            data.insert(index: (9 - i) * 5, content: (9 - i) * 5)
//            print(data.holes)
//        }
//        for i in 0 ..< 10{
//            data.insert(index: (9 - i) * 5 + 1, content: (9 - i) * 5 + 1)
//            print(data.holes)
//        }
//        for i in 0 ..< 10{
//            data.insert(index: (9 - i) * 5 + 2, content: (9 - i) * 5 + 2)
//            print(data.holes)
//        }
//        for i in 0 ..< 10{
//            data.insert(index: (9 - i) * 5 + 3, content: (9 - i) * 5 + 3)
//            print(data.holes)
//        }
//        for i in 0 ..< 10{
//            data.insert(index: (9 - i) * 5 + 4, content: (9 - i) * 5 + 4)
//            print(data.holes)
//        }
//        print(data.data)
//    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
