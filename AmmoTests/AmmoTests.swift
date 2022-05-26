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
        let ctx = Context(size: CGSize(width: 100, height: 100), scale: 3)
        
        ctx.begin { ctx in
            ctx.context.setFillColor(UIColor.red.cgColor)
            ctx.context.fill(CGRect(x: 10, y:10, width: 80, height: 10))
            let ii = UIImage(named: "i")!.cgImage
//            ctx.drawImage(image: ii!, rect: CGRect(x: 50, y: 50, width: 50, height: 50))
            ctx.drawScaleImage(image: ii!, rect: CGRect(x: 30, y: 30, width: 50, height: 50),mode: .fillScale)
            
            let a = NSAttributedString(string: "dsds|dsds", attributes: [
                .font:UIFont.systemFont(ofSize: 20),
                .foregroundColor:UIColor.red
            ])
            let pathframe = CGRect(x: 30, y: 30, width: 30, height: 30)
            ctx.drawString(string: a as CFAttributedString, constaint: pathframe)
            
        }
        let img = ctx.image!
        
        print(img)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

