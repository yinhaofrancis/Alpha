//
//  swfconcurrentcy.swift
//  AlphaTests
//
//  Created by hao yin on 2021/9/22.
//

import XCTest
@testable import Alpha
class swfsetting: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        pQueue().sync {
            self.json = ["ab":"asda","o":["qq":123,"pp":123.5,"k":true],"a":["a","b",["test":"dsds"]],"dd":"1988-08-09 12:22:33.123"]
            
            XCTAssert(self.a == "dsds")
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            
            XCTAssert(self.b == 123)
            XCTAssert(self.json?.o.pp == 123.5)
            XCTAssert(self.d == df.date(from: "1988-08-09 12:22:33.123"))
            XCTAssert(self.bo == true)
            XCTAssert(self.arr?[0].str() == "a")
            XCTAssert(self.arr?[1].str() == "b")
            XCTAssert(self.jso?.qq == 123)
            XCTAssert(self.jso?.pp == 123.5)
            XCTAssert(self.jso?.k == true)
            var a = self.json
            let db = Setting.db
            let fc = Function(name: "make", nArg: 1) { fuc, argc in
                fuc.ret(v: fuc.valueJSON(index: 0)?.jsonString ?? "null")
            }
            db.addFunction(function: fc)
            a?.setKeyValue(dynamicMember: "rowid", json: nil)
            try? db.save(jsonName: "sss", json: a!)
            try? db.exec(sql: "select make(JSON) from sss")
        }
    }
    func testEx() throws {
        pQueue().sync {
            let jj:JSON = ["ab":"asda","o":["qq":123,"pp":123.5,"k":true],"a":["a","b",["test":"dsds"]],"dd":"1988-08-09 12:22:33.123"]
            self.$j.add(json: jj)
            print(self.j)
        }
    }
    
    @Setting(name: "ddd")
    var json:JSON?
    
    @SettingStringKey(name:"ddd",keys:"a[2].test")
    var a:String?
    
    @SettingIntKey(name:"ddd",keys:"o.qq")
    var b:Int?
    
    @SettingDateKey(name:"ddd",keys:"dd")
    var d:Date?

    @SettingBoolKey(name:"ddd",keys:"o.k")
    var bo:Bool?
    
    @SettingArrayKey(name:"ddd",keys:"a")
    var arr:[JSON]?
    
    @SettingObjectKey(name:"ddd",keys:"o")
    var jso:JSON?
    
    @JSONRequest(key: "aaa")
    var j:[JSON]
}

public struct pQueue{
    public var name:String?
    public init(name:String? = nil){
        self.name = name
    }
    public func async(_ call:@escaping ()->Void){
        var thread:pthread_t?
        class run{
            var call:()->Void
            init(call:@escaping ()->Void){
                self.call = call
            }
        }
        let r = run(call: call)
        pthread_create(&thread, nil, { ob in
            Unmanaged<run>.fromOpaque(ob).autorelease().takeUnretainedValue().call()
            return nil
        }, Unmanaged.passRetained(r).toOpaque())
    }
    public func sync(_ call:@escaping ()->Void){
        var thread:pthread_t?
        class run{
            var call:()->Void
            init(call:@escaping ()->Void){
                self.call = call
            }
        }
        let r = run(call: call)
        pthread_create(&thread, nil, { ob in
            Unmanaged<run>.fromOpaque(ob).takeUnretainedValue().call()
            return nil
        }, Unmanaged.passUnretained(r).toOpaque())
        guard let th = thread else { return }
        pthread_join(th, nil)
    }
}
