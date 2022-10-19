//
//  Cache.swift
//  RenderImage
//
//  Created by wenyang on 2022/10/19.
//

import Foundation
import CryptoKit
import CoreImage

public protocol DataItem{
    var data:Data { get }
    static func create(data:Data)->Self
}
extension Data:DataItem{
    public var data: Data { self }
    public static func create(data: Data) -> Data {
        return data
    }
}
public protocol CacheInMemory{
    associatedtype Content:AnyObject
    
    func cache(key:String,content:Content)
    
    func content(key:String)->Content?
    
}

public protocol CacheInDisk {
    associatedtype Content:DataItem
    
    func cache(key:String,content:Content)
    
    func content(key:String)->Content?
}


public class MemoryCache<T:AnyObject>:CacheInMemory{
    public func cache(key: String, content: T) {
        pthread_rwlock_wrlock(&self.lock)
        defer{
            pthread_rwlock_unlock(&self.lock)
        }
        self.map[key] = WeakProxy(content: content)
    }
    
    public func content(key: String) -> T? {
        pthread_rwlock_rdlock(&self.lock)
        defer{
            pthread_rwlock_unlock(&self.lock)
        }
        return self.map[key]?.content
    }
    
    public typealias Content = T
    
    public var map:[String:WeakProxy<T>] = [:]
    
    public var lock:pthread_rwlock_t = .init()
    
    public init() {
        pthread_rwlock_init(&self.lock, nil)
    }
    deinit{
        pthread_rwlock_destroy(&self.lock)
    }
}

public class DiskCache<T:DataItem>:CacheInDisk{
    public func cache(key: String, content: T) {
        guard let name = DiskCache.name(key: key) else { return }
        guard let url = self.url(name: name) else { return }
        pthread_rwlock_wrlock(&self.lock)
        defer{
            pthread_rwlock_unlock(&self.lock)
        }
        do{
            self.write(file: try FileHandle(forWritingTo: url), content: content)
        }catch{
            return
        }
    }
    public func content(key: String) -> T? {
        guard let name = DiskCache.name(key: key) else { return nil }
        guard let url = self.url(name: name) else { return nil }
        pthread_rwlock_rdlock(&self.lock)
        defer{
            pthread_rwlock_unlock(&self.lock)
        }
        do{
            return self.read(file: try FileHandle(forReadingFrom: url))
        }catch{
            return nil
        }
    }
    public func copy(key:String,source:URL){
        guard let name = DiskCache.name(key: key) else { return }
        guard let url = self.url(name: name) else { return }
        var dic:ObjCBool = ObjCBool.init(false)
        pthread_rwlock_wrlock(&self.lock)
        defer{
            pthread_rwlock_unlock(&self.lock)
        }
        if(FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &dic)){
            if(dic.boolValue == false){
                try? FileManager.default.removeItem(at: url)
            }
        }
        try? FileManager.default.copyItem(at: source, to: url)
    }
    public func write(file:FileHandle,content:T){
        if #available(iOSApplicationExtension 13.4, *) {
            try? file.write(contentsOf: content.data)
        } else {
            file.write(content.data)
        }
    }
    public func read(file:FileHandle)->T?{
        if #available(iOSApplicationExtension 13.4, *) {
            guard let data = try? file.readToEnd() else { return nil }
            return T.create(data: data)
        } else {
            let data = file.readDataToEndOfFile()
            return T.create(data: data)
        }
    }
    public typealias Content = T
    
    public static func name(key:String)->String?{
        var md5 = Insecure.MD5()
        guard let data = key.data(using: .utf8) else { return nil }
        md5.update(data: data)
        return md5.finalize().description.components(separatedBy: .whitespaces).last
    }
    private var _dictionaryUrl:URL?{
        if #available(iOSApplicationExtension 16.0, *) {
            return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(components: "DiskCache")
        } else {
            return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("DiskCache")
        }
    }
    public func url(name:String)->URL?{
        if #available(iOSApplicationExtension 16.0, *) {
            return self.dictionary?.appending(components: name)
        } else {
            return self.dictionary?.appendingPathComponent(name)
        }
    }
    public var dictionary:URL?{
        guard let url = self._dictionaryUrl else { return nil }
        var b:ObjCBool = .init(false)
        FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &b)
        if(b.boolValue == false){
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            }catch{
                return nil
            }
        }
        return url
    }
    public var lock:pthread_rwlock_t = .init()
    
    public init() {
        pthread_rwlock_init(&self.lock, nil)
    }
    deinit{
        pthread_rwlock_destroy(&self.lock)
    }
}

public class Downloader<Content:DataItem>:NSObject,URLSessionDownloadDelegate{
    
    public typealias CallBack = (Content?,Bool)->Void
    
    struct Task{
        var task:URLSessionTask
        var callback:[CallBack]
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let key = downloadTask.originalRequest?.url else { return }
        self.cache.copy(key: key.absoluteString, source: location)
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let key = task.originalRequest?.url else { return }
        pthread_mutex_lock(&self.lock)
        defer{
            pthread_mutex_unlock(&self.lock)
        }
        let task = self.map.removeValue(forKey: key)
        self.queue.addOperation {
            let data = self.cache.content(key: key.absoluteString)
            task?.callback.forEach({ call in
                call(data,true)
            })
        }
    }
    public var cache:DiskCache<Content>
    
    
    
    lazy var session:URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: self.queue)
    }()
    public func download(url:URL,callback:@escaping CallBack){
        self.queue.addOperation {
            pthread_mutex_lock(&self.lock)
            defer{
                pthread_mutex_unlock(&self.lock)
            }
            if(self.map[url] == nil){
                if let data = self.cache.content(key: url.absoluteString){
                    self.queue.addOperation {
                        callback(data,true)
                    }
                    return
                }
                let task = self.session.downloadTask(with: URLRequest(url: url))
                self.map[url] = Task(task: task, callback: [callback])
                task.resume()
            }else{
                self.map[url]?.callback.append(callback)
            }
        }
    }
    public var queue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    public override init(){
        self.cache = DiskCache()
        pthread_mutex_init(&self.lock, nil)
        super.init()
    }
    
    private var map:[URL:Task] = [:]
    
    public var lock:pthread_mutex_t = .init()
    
    deinit{
        pthread_mutex_destroy(&self.lock)
    }
    
}
public let sharedDownloader:Downloader<Data> = Downloader()
public typealias Filter = (CIImage?)->CIImage?
public let sharedMemoryCache = MemoryCache<CIImage>()
extension CoreImageView{
    public func load(url:URL,filter: Filter? = nil){
        if let data = sharedMemoryCache.content(key: url.absoluteString){
            self.image = filter?(data) ?? data
        }else{
            sharedDownloader.download(url: url) { data, flag in
                if let data = data {
                    let source = CIImage(data: data)
                    let filter = filter?(source) ?? source
                    if let needCache = source{
                        sharedMemoryCache.cache(key: url.absoluteString, content: needCache)
                    }
                    DispatchQueue.main.async {
                        self.image = filter
                    }
                }
            }
        }
    }
}
