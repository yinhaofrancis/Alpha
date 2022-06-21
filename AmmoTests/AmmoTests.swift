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

    @DBWorkFlow(name: "data")
    var queue:DataBaseWorkFlow
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    
    func testExample() async throws {
        let ctx = Context(size: CGSize(width: 100, height: 100), scale: 3)

        let img = await ctx.render { ctx in
            ctx.context.setFillColor(UIColor.red.cgColor)
            ctx.context.fill(CGRect(x: 10, y:10, width: 80, height: 10))
            let ii = UIImage(named: "i")!.cgImage
            ctx.drawScaleImage(image: ii!, rect: CGRect(x: 30, y: 30, width: 50, height: 50),mode: .fillScaleClip)

            let a = NSAttributedString(string: "dsds|dsds", attributes: [
                .font:UIFont.systemFont(ofSize: 20),
                .foregroundColor:UIColor.red
            ])
            let pathframe = CGRect(x: 30, y: 30, width: 30, height: 30)
            ctx.drawString(string: a as CFAttributedString, constaint: pathframe)

        }
        print(img)
    }
    func testCon() async throws{
        let data:DataBaseSet<testA> = try await DataBaseSet(database: "data")
        print(try await data.array)
    }
    func testZip()throws{
        let d = try Deflate()
        var data = Data()
        for _ in 0 ..< 100 {
            data.append(try d.push(data: "123123123123".data(using: .utf8)!))
            data.append(try d.push(data: "qweqweqweqweqwe".data(using: .utf8)!))
            data.append(try d.push(data: "123123123123".data(using: .utf8)!))
            data.append(try d.push(data: "qweqweqweqweqwe".data(using: .utf8)!))
            print(data)
        }
        data.append(try d.push(data: "qweqweqweqweqwe".data(using: .utf8)!,finish: true))
        d.reset()
        
        print(data)
        let inn = Inflate()
        var r = try inn.push(data: data.subdata(in: 0 ..< 10))
        let r2 = try inn.push(data: data.subdata(in: 10 ..< data.count),finish: true)
        r.append(r2)
        let strr = String(data: r, encoding: .utf8)
        print(strr)
    }
    func testcomp() async throws {
        let u = self.queue.wdb.url
        let uu = URL(string: u.absoluteString.appending("2"))
        FileManager.default.createFile(atPath: uu!.path, contents: nil)
        await try Deflate.compress(source: u, destination: uu!)
        
        
        
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
