//
//  swfconcurrentcy.swift
//  AlphaTests
//
//  Created by hao yin on 2021/9/22.
//

import XCTest
@testable import Alpha
class swfconcurrentcy: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        pQueue().sync {
            self.json = ["ab":"asda","o":123,"dd":Date().timeIntervalSince1970]
            XCTAssert(self.a == "asda")
            
            XCTAssert(self.b == 123)
            print(self.d)
            Setting.db.writeSync { db in
                
            }
            
        }
    }
    @Setting(name: "ddd")
    var json:JSON?
    
    @SettingStringKey(name:"ddd",keys:"ab")
    var a:String?
    
    @SettingIntKey(name:"ddd",keys:"o")
    var b:Int?
    
    @SettingDateKey(name:"ddd",keys:"dd")
    var d:Date?
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
