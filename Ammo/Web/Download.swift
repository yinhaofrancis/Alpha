import Foundation
import CommonCrypto
import ImageIO

public protocol CacheContent{
    func delete(name:String)
    func detach(name:String)
    static func name(url:String)->String?
    func write(name:String,data:Data)
    func exist(name:String)->Bool
    func close(name:String)
    func copy(name:String,local:URL)
    func queryAllData(name:String)->Data?
    func queryMd5(name:String)->String?
}
public class DiskCache{
    public var lock:DispatchSemaphore = DispatchSemaphore(value: 1)
    public class MemoryItem{
        public var data:Data
        public var time:TimeInterval = 0
        public var count:Int = 0
        public var key:String
        init(data:Data,key:String){
            self.data = data
            self.key = key
        }
    }
    
    public var map:[String:MemoryItem] = [:]
    
    public func insert(data:Data,key:String){
        self.lock.wait()
        let mi = MemoryItem(data: data, key: key)
        mi.time = Date().timeIntervalSince1970
        mi.count = 1
        self.map[key] = mi
        self.lock.signal()
    }
    public func query(name:String)->Data?{
        self.lock.wait()
        defer{
            self.lock.signal()
        }
        guard let data = self.map[name] else { return nil }
        data.count += 1;
        return data.data
        
    }
    public func remove(name:String){
        self.lock.wait()
        self.map.removeValue(forKey: name)
        self.lock.signal()
    }
    func remove(count:Int){
        self.lock.wait()
        let v = self.map.values.sorted { l, r in
            if l.count < r.count{
                return true
            }else if l.count == r.count{
                return l.time < r.time
            }else{
                return false
            }
        }
        v[0 ..< count].forEach { i in
            self.map.removeValue(forKey: i.key)
        }
        self.lock.signal()
    }
}
public class Cache:CacheContent,CustomDebugStringConvertible{
    public var debugDescription: String{
        return self.dictionaryUrl?.path ?? ""
    }
 
    private var dispatchSem:DispatchSemaphore = DispatchSemaphore(value: 1)
    private var map:[String:FileHandle] = [:]
        
    public var CacheDictionaryName:String = "Cache"
    public static func name(url:String)->String?{
        guard let data = url.data(using: .utf8) else  { return nil }
        return Md5.update(data: data).hex
    }
    public var dictionaryUrl:URL?{
        Cache.cacheDictionary(name: self.CacheDictionaryName,refresh: false)
    }
    @discardableResult
    public static func cacheDictionary(name:String,refresh:Bool)->URL?{
        do {
            let url = try FileManager.default.url(for: .cachesDirectory, in: .allDomainsMask, appropriateFor: nil, create: true).appendingPathComponent("Beta").appendingPathComponent(name)
            var b:ObjCBool = .init(false)
            if refresh{
                try? FileManager.default.removeItem(at: url)
            }
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &b){
                if b.boolValue{
                    return url
                }
            }
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            return url
        } catch {
            return nil
        }
    }
    public func cacheFullData(data:Data,name:String){
        guard let dic = self.dictionaryUrl else { return }
        let name = dic.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: name.path){
            do{
                try FileManager.default.removeItem(at: name)
            }catch{
                return
            }
        }
        FileManager.default.createFile(atPath: name.path, contents: data, attributes: nil)
    }
    public func copy(name:String,local:URL){
        self.dispatchSem.wait()
        defer{
            self.map.removeValue(forKey: name)
            self.dispatchSem.signal()
        }
        guard let path = self.fileUrl(name: name)?.path else { return }
        try? FileManager.default.copyItem(atPath: local.path, toPath: path)
    }
    public func queryAllData(name:String)->Data?{

        guard let name = self.fileUrl(name: name) else { return nil }
        if FileManager.default.fileExists(atPath: name.path){
            do{
                return try Data(contentsOf: name)
            }catch{
                return nil
            }
        }
        return nil
    }
    public func queryMd5(name:String)->String?{
        guard let data = self.queryAllData(name: name) else { return nil }
        return Md5.update(data: data).base64EncodedString()
    }
    public func writeToFile(name:String)->FileHandle?{
        self.dispatchSem.wait()
        defer{
            self.dispatchSem.signal()
        }
        if let fh = self.map[name]{
            return fh
        }
        guard let dic = self.dictionaryUrl else { return nil }
        
        do{
            let u = dic.appendingPathComponent(name)
            if !FileManager.default.fileExists(atPath: u.path){
                FileManager.default.createFile(atPath: u.path, contents: nil, attributes: nil)
            }
            let handle = try FileHandle(forWritingTo: u)
            self.map[name] = handle
            return handle
        }catch{
            print(error)
            return nil
        }
    }
    public func readToFile(name:String)->FileHandle?{
        guard let dic = self.dictionaryUrl else { return nil }
        
        do{
            return try FileHandle(forReadingFrom: dic.appendingPathComponent(name))
        }catch{
            return nil
        }
    }
    public func delete(name:String){
        self.dispatchSem.wait()
        defer{
            self.dispatchSem.signal()
        }
        self.map.removeValue(forKey: name)
        guard let name = self.fileUrl(name: name) else { return }
        try? FileManager.default.removeItem(at: name)
    }
    public func detach(name:String){
        self.dispatchSem.wait()
        defer{
            self.dispatchSem.signal()
        }
        self.map.removeValue(forKey: name)
    }
    public func fileUrl(name:String)->URL?{
        guard let dic = self.dictionaryUrl else { return nil }
        let name = dic.appendingPathComponent(name)
        return name
    }
    public func write(name:String,data:Data){
        guard let handle = writeToFile(name: name) else { return }
        Cache.write(handle: handle, data: data)
    }
    public func exist(name:String)->Bool{
        self.dispatchSem.wait()
        defer{
            self.dispatchSem.signal()
        }
        if self.map[name] != nil{
            return true
        }
        guard let file = self.fileUrl(name: name) else { return false }
        if FileManager.default.fileExists(atPath: file.path){
            return true
        }else{
            return false
        }
    }
    public func close(name:String){
        self.dispatchSem.wait()
        defer{
            self.dispatchSem.signal()
        }
        guard let handle = writeToFile(name: name) else { return }
        self.map.removeValue(forKey: name)
        Cache.close(handle: handle)
        
    }

    public init(refresh:Bool = false){
        Cache.cacheDictionary(name: self.CacheDictionaryName,refresh: refresh)
    }
    public static var shared:Cache = Cache()
}

extension Cache{
    static func read(handle:FileHandle,len:Int)->Data{
        if #available(iOS 13.4, *) {
            return (try? handle.read(upToCount: len)) ?? Data()
        } else {
            return handle.readData(ofLength: len)
        }
    }
    static func write(handle:FileHandle,data:Data){
        if #available(iOS 13.4, *) {
            try? handle.write(contentsOf: data)
        } else {
            handle.write(data)
        }
    }
    static func read(handle:FileHandle,count:Int)->Data?{
        if #available(iOS 13.4, *) {
            return try? handle.read(upToCount: count)
        } else {
            return handle.readData(ofLength: count)
        }
    }
    static func append(handle:FileHandle,data:Data){
        if #available(iOS 13.4, *) {
            do{
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
            }catch{
                return
            }
        } else {
            handle.write(data)
            handle.seekToEndOfFile()
        }
    }
    static func truncate(handle:FileHandle?){
        if #available(iOS 13.0, *) {
            try? handle?.truncate(atOffset: 0)
        } else {
            handle?.truncateFile(atOffset: 0)
        }
    }
    static func close(handle:FileHandle?){
        if #available(iOS 13.0, *) {
            try? handle?.close()
        } else {
            handle?.closeFile()
        }
    }
}

extension String{
    public var copyBuffer:UnsafeRawPointer{
        let data = self.data(using: .utf8)
        let buffer:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: self.count)
        data?.copyBytes(to: buffer, count: self.count)
        return UnsafeRawPointer(buffer)
    }
}
@propertyWrapper
public struct Lock<T>{
    public var sem = DispatchSemaphore(value: 1)
    public var wrappedValue:T{
        get{
            self.sem.wait()
            let v = value
            self.sem.signal()
            return v
        }
        set{
            self.sem.wait()
            self.value = newValue
            self.sem.signal()
        }
        
    }
    private var value:T
    
    public init(wrappedValue:T){
        self.value = wrappedValue
    }
}

public protocol DataTransform{
    associatedtype Result
    
    static func makeContent(data:Data?)->Result?
}
public class DataOrigin:DataTransform{
    public typealias Result = Data
    
    public static func makeContent(data: Data?) -> Data? {
        return data
    }
}

public class DataImageDataSource:DataTransform{
    public typealias Result = CGImageSource
    
    public static func makeContent(data: Data?) -> CGImageSource? {
        guard let rdata = data else { return nil }
        if let source = CGImageSourceCreateWithData(rdata as CFData, nil){
            if CGImageSourceGetStatus(source) == .statusComplete{
                return source
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
}

public class DataCGImage:DataTransform{
    public typealias Result = CGImage
    
    public static func makeContent(data: Data?) -> CGImage? {
        guard let rdata = data else { return nil }
        if let source = CGImageSourceCreateWithData(rdata as CFData, nil){
            if CGImageSourceGetStatus(source) == .statusComplete{
                return CGImageSourceCreateImageAtIndex(source, 0, nil);
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
}

public class Downloader<T:DataTransform,R>:NSObject,URLSessionDataDelegate,URLSessionDownloadDelegate where T.Result == R {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let rep = downloadTask.originalRequest?.url?.absoluteString else { return }
        guard let name = Cache.name(url: rep) else { return }
        self.cache.copy(name: name, local: location)
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let rep = dataTask.originalRequest?.url?.absoluteString else { return }
        guard let name = Cache.name(url: rep) else { return }
        self.cache.write(name: name, data: data)
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let rep = task.originalRequest?.url?.absoluteString else { return }
        guard let name = Cache.name(url: rep) else { return }
        if error != nil {
            self.cache.delete(name: name)
        }else{
            self.cache.detach(name: name)
        }
        self.lock.wait()
        self.urls.remove(name)
        self.lock.signal()
        print("downloaded")
        self.callbackLock.wait()
        let a = self.callbacks.removeValue(forKey: name)
        self.callbackLock.signal()
        a?.forEach({ c in
            c()
        })
    }
    lazy private var configuration:URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        return config
    }()
    
    lazy private var session:URLSession = {
        URLSession(configuration: self.configuration, delegate:self, delegateQueue: self.queue)
    }()
    
   private func download(url:URL)->String?{
        guard let name = Cache.name(url: url.absoluteString) else { return nil }
        if self.needDownload(name: name){
            self.session.dataTask(with: url).resume()
            self.urls.insert(name)
            print("launch download")
        }
        return name
    }
    public func download(url:URL,callback:@escaping (R?)->Void){
        self.lock.wait()
        print("try download")
        guard let name = self.download(url: url) else {self.lock.signal();callback(nil);return}
        self.lock.signal()
        if !self.hasDownload(name: name){
            callback(self.createContent(name: name))
            print("read cache")
        }else{
            print("wait download")
            self.observerDownload(name:name) { [weak self] in
                callback(self?.createContent(name: name))
                print("handle download")
            }
        }
    }
    private func createContent(name:String)->R?{
        let data = self.cache.queryAllData(name: name)
        let r = T.makeContent(data:data)
        if r == nil && data != nil{
            self.cache.delete(name:name)
        }
        return r
    }
    
    public var cache:CacheContent
    public var notificationCenter = NotificationCenter()
    private var lock:DispatchSemaphore = DispatchSemaphore(value: 1)
    private var callbackLock:DispatchSemaphore = DispatchSemaphore(value: 1)
    public var queue:OperationQueue = OperationQueue()
    public var callbacks:[String:[()->Void]] = [:]
    public func needDownload(name:String)->Bool{
        if(!urls.contains(name) && !self.cache.exist(name: name)){
            return true
        }
        return false
    }
    private var urls:Set<String> = Set()
    public init(cache:CacheContent = Cache.shared){
        self.cache = cache
        super.init()
    }
    public func observerDownload(name:String,callback:@escaping ()->Void){
        self.callbackLock.wait()
        defer{
            self.callbackLock.signal()
        }
        var calls:[()->Void] = (self.callbacks[name] == nil ? [] : self.callbacks[name]!)
        calls.append(callback)
        self.callbacks[name] = calls
    }
    public func delete(url:URL){
        guard let name = Cache.name(url: url.absoluteString) else { return }
        self.cache.delete(name: name)
    }
    public func hasDownload(name:String)->Bool{
        self.urls.contains(name)
    }
}
extension Notification.Name{
    public static var DownloadTaskEnd = Notification.Name.init(rawValue: "DownloadTaskEnd")
}

public class Md5{
    var ctx:CC_MD5_CTX
    public init(){
        self.ctx = CC_MD5_CTX()
        CC_MD5_Init(&self.ctx)
    }
    @discardableResult
    public func update(data:Data)->Md5{
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        data.copyBytes(to: buffer, count: data.count)
        CC_MD5_Update(&self.ctx, buffer, CC_LONG(data.count))
        buffer.deallocate()
        return self
    }
    public func final()->Data{
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        
        CC_MD5_Final(buffer, &self.ctx)
        let data = Data(bytes: buffer, count: Int(CC_MD5_DIGEST_LENGTH))
        buffer.deallocate()
        return data
    }
    public static func update(data:Data)->Data{
        Md5().update(data: data).final()
    }
}
extension Data{
    public var hex:String{
        self.reduce("") { partialResult, i in
            partialResult + String(format: "%02x", i)
        }
    }
}

public let dataDownload = Downloader<DataOrigin,Data>()


public let imageSourceDownload = Downloader<DataImageDataSource,CGImageSource>()


public let imageDownload = Downloader<DataCGImage,CGImage>()

public class StaticImageDownloader{
    public init?(){
    }
    public static let shared:StaticImageDownloader = {
        StaticImageDownloader()
    }()!
    public func downloadImage(url:URL,callback:@escaping (CGImage?)->Void){

        imageDownload.download(url: url) { i in
            DispatchQueue.main.async {
                callback(i)
            }
        }
    }
}
