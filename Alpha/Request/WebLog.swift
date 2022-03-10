//
//  WebLog.swift
//  Alpha
//
//  Created by hao yin on 2022/3/9.
//

import Foundation



public class Log:Object{
    
    @Col
    public var method:String = ""
    
    @Col
    public var url:String = ""
    
    @Col
    public var state:String = ""
    
    @Col
    public var reqHeader:JSONType = JSONType(json: JSON(nil))
    
    @Col
    public var respHeader:JSONType = JSONType(json: JSON(nil))
    
    @Col
    public var data:Data = Data()
    
}
@objc(RestoreLog)
public class RestoreLog:NSObject{
    private var session:DataBasePool
    @objc public init(name:String) throws{
        self.session = try DataBasePool(name: name)
        self.session.writeSync { db in
            let log = Log()
            try log.create(db: db)
        }
    }
    @objc public func write(respone:HTTPURLResponse,request:URLRequest,data:Data){
        self.session.write { db in
            let log = Log()
            log.state = "\(respone.statusCode)"
            log.method = request.httpMethod ?? ""
            log.url = request.url?.absoluteString ?? ""
            log.reqHeader = JSONType(json: request.allHTTPHeaderFields ?? [:])
            log.respHeader = JSONType(json: respone.allHeaderFields as! [String:String])
            log.data = data
            try log.save(db: db)
        }
    }
    @objc public func query(callback:@escaping ([Log])->Void){
        let req = ObjectRequest<Log>(table: "Log")
        self.session.read { db in
            let r = try req.query(db: db)
            DispatchQueue.main.async {
                callback(r)
            }
        }
    }
}
