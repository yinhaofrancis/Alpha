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


    func testFF(){
        
    }
    
    
    func testExample() throws {
        let a = [UIColor.red,UIColor.yellow,UIColor.blue]
        let svi = StackViewItem(viewItems: (0 ..< 3).map { i in
            let vt = ViewItem()
            vt.color = a[i].cgColor
            vt.item.grow = Double(i + 1)
            return vt
        })
        svi.stack.width = 100
        svi.stack.height = 50
        svi.stack.align = .fill
        
        let c = Context(size: CGSize(width: 100, height: 50), scale: 3)
        svi.item.layout()
        svi.draw(ctx: c)
        let img = c.image!
        print(img)
        
    }
   
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
