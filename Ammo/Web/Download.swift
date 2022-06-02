//
//  Download.swift
//  Ammo
//
//  Created by hao yin on 2022/6/2.
//

import Foundation
import CommonCrypto

public protocol DataBox{
    func handleData(data:Data)
    
    func endData(error:Error?)
    var url:URL { get }
    init(url:URL)
}
public class PlainData:DataBox{
    public var url: URL
    
    public required init(url: URL) {
        self.url = url
    }
    
    public func endData(error: Error?) {
        
    }
    
    public func handleData(data: Data) {
        self.queue.async {
            self.data.append(data)
        }
    }
    
    var data:Data = Data()
    var queue:DispatchQueue = DispatchQueue(label: "saveData")
    
}

extension Data{
    fileprivate var bufferData:UnsafeMutablePointer<UInt8>{
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.count)
        self.copyBytes(to: buffer, count: self.count)
        return buffer
    }
    fileprivate var hexString:String{
        return self.reduce(into: "") { partialResult, i in
            partialResult.append(String(format: "%02x", i))
        }
    }
}

public class MD5Check{
    var ctx:CC_MD5_CTX
    public init() {
        var cc:CC_MD5_CTX = CC_MD5_CTX()
        CC_MD5_Init(&cc)
        self.ctx = cc
    }
    public func append(data:Data){
        let b = data.bufferData
        defer{
            b.deallocate()
        }
        CC_MD5_Update(&self.ctx, b, CC_LONG(data.count))
        
    }
    public func finish()->Data{
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        defer{
            buffer.deallocate()
        }
        CC_MD5_Final(buffer, &self.ctx)
        return Data(bytes: buffer, count: Int(CC_MD5_DIGEST_LENGTH))
    }
}
public class DownloadDataHandler<Box:DataBox>:NSObject,URLSessionDataDelegate{
    private class DataBoxHolder<Box:DataBox>{
        var box:Box
        var md5:Data?
        var md5Check:MD5Check = MD5Check()
        var contentSize:UInt64?
        public init(box:Box){
            self.box = box
        }
    }
    private var queue = DispatchQueue(label: "processData", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    private var map:[URLSessionTask:DataBoxHolder<Box>] = [:]
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.queue.async {
            self.map[dataTask]?.box.handleData(data: data)
            if self.map[dataTask]?.md5 != nil{
                self.map[dataTask]?.md5Check.append(data: data)
            }
        }
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.queue.async(execute: DispatchWorkItem(qos: .background, flags: .barrier, block: {
            defer{
                self.map.removeValue(forKey: task)
            }
            if let e = error{
                self.map[task]?.box.endData(error: e)
            }else{
                if let md5 = self.map[task]?.md5,let current = self.map[task]?.md5Check.finish(){
                    if md5 != current{
                        self.map[task]?.box.endData(error: NSError(domain: "md5 check fail", code: 0))
                    }else{
                        self.map[task]?.box.endData(error: error)
                    }
                }else{
                    self.map[task]?.box.endData(error: error)
                }
            }
            
        }))
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httprep = response as? HTTPURLResponse else { completionHandler(.cancel);return }
        
        if let headermd5 = httprep.value(forHTTPHeaderField: "Content-MD5"){
            self.map[dataTask]?.md5 = Data(base64Encoded: headermd5)
        }
        completionHandler(.allow)
    }
    public func add(task:URLSessionTask,box:Box){
        self.queue.sync(execute: DispatchWorkItem(qos: .userInteractive, flags: .barrier, block: {
            self.map[task] = DataBoxHolder(box: box)
            task.resume()
        }))
    }
}

public class DownloadSession<Box:DataBox>{
    public var session:URLSession
    public var handle:DownloadDataHandler<Box>
    public init(configuration:URLSessionConfiguration){
        let handle = DownloadDataHandler<Box>()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4
        self.handle = handle
        self.session = URLSession(configuration: configuration, delegate: handle, delegateQueue: queue)
    }
    public func download(box:Box){
        let task = self.session.dataTask(with: box.url)
        self.handle.add(task: task,box: box)
    }
}
