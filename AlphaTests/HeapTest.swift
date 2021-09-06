//
//  HeapTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/17.
//

import XCTest
@testable import Alpha
class HeapTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeap() throws {
        let a = MaxHeap<UInt32>()
        
   
        for _ in 0..<100 {
            a.insert(object: arc4random() % 1000)
            print(a)
        }
        
        print(a)
        var array:[UInt32] = []
        for _ in 0..<100 {
            array.append(a.remove())
        }
        print(array)
        for i in 0 ..< (array.count - 1) {
            XCTAssert(array[i] >= array[i + 1])
        }
    }
    func testMinHeap() throws {
        let a = MinHeap<UInt32>()
        
   
        for _ in 0..<100 {
            a.insert(object: arc4random() % 1000)
            print(a)
        }
        
        print(a)
        var array:[UInt32] = []
        for _ in 0..<100 {
            array.append(a.remove())
        }
        print(array)
        for i in 0 ..< (array.count - 1) {
            XCTAssert(array[i] <= array[i + 1])
        }
    }
    func testRemoveHeap() throws {
        let a = MinHeap<UInt32>()
        
   
        for _ in 0..<10 {
            a.insert(object: arc4random() % 100)
            print(a)
        }
        for _ in 0..<10{
            a.remove(node: a.firstNode)
            print(a)
        }
    }
    func testCache() throws{
        let cache = Cache<Int>()

        let group = DispatchGroup()
        for i in 0 ..< 100{
            group.enter()
            DispatchQueue.global().async {
                cache.setContent(key: "\(i)", content: i)
                group.leave()
            }
            
        }
        for i in 0 ..< 100000 {
            group.enter()
            DispatchQueue.global().async {
                let a = cache.content(key: "\(i % 100)")
                XCTAssert(a == i % 100)
                group.leave()
            }
        }
        let a = XCTestExpectation(description: "time out")
        group.notify(queue: .main) {
            a.fulfill()
            
            print("finish")
        }
        self.wait(for: [a], timeout: 1000)
    }
    func testWrite(){
        
        measure {
            let cache = Cache<Data>()
            for i in 0 ..< 1000000 {
                cache.setContent(key: "\(i)", content: "jsdfgaskjdfgk".data(using: .utf8)!)
            }
            print(cache.size)
        }
    }
    func testMss(){
        let cache = Cache<Data>()
        for i in 0 ..< 1000000 {
            cache.setContent(key: "\(i)", content: "dfajksfgaksjhdfgajskdfgajsdfgaskjdfgk".data(using: .utf8)!)
        }
        measure {
            for i in 0 ..< 1000000{
                cache.content(key: "@@\(arc4random() % 70000)")
            }
        }
        print(cache.size)
    }
    func testRead(){
        let cache = Cache<Data>()
        for i in 0 ..< 1000000 {
            cache.setContent(key: "\(i)", content: "dfajhsgdjhfasgdfjaksgdfajksfgaksjhdfgajskdfgajsdfgaskjdfgk".data(using: .utf8)!)
        }
        measure {
            for i in 0 ..< 1000000{
                cache.content(key: "\(i)")
            }
        }
        print(cache.size)
    }
    
}
