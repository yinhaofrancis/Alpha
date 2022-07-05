import Foundation
import CommonCrypto
import ImageIO

public protocol CacheContent{
    func delete(name:String)
    func detach(name:String)
    static func name(url:String)->String?
    func write(name:String,data:Data)
    func exist(name:String,complete:Bool)->Bool
    func close(name:String)
    func copy(name:String,local:URL)
    func queryAllData(name:String)->Data?
    func queryMd5(name:String)->String?
}

public class Cache:CacheContent{
 
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
        guard let handle = writeToFile(name: name) else { return }
        defer{
            
            self.map.removeValue(forKey: name)
            self.dispatchSem.signal()
            Cache.close(handle: handle)
        }
        Cache.truncate(handle: handle)
        do{
            let from = try FileHandle(forReadingFrom: local)
            repeat{
                let data = Cache.read(handle: from, len: 200 * 1024)
                if(data.count == 0){
                    break
                }else{
                    Cache.write(handle: handle, data: data)
                }
            }while(true)
        }catch{
            return
        }
        
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
    public func exist(name:String,complete:Bool = false)->Bool{
        self.dispatchSem.wait()
        defer{
            self.dispatchSem.signal()
        }
        if self.map[name] != nil{
            return complete ? false : true
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


public class Downloader:NSObject,URLSessionDataDelegate,URLSessionDownloadDelegate {
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
        self.notificationCenter.post(name: .DownloadTaskEnd, object: name)
    }
    lazy private var configuration:URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        return config
    }()
    
    lazy private var session:URLSession = {
        URLSession(configuration: self.configuration, delegate:self, delegateQueue: self.queue)
    }()
    
    public func download(url:URL)->String?{
        guard let name = Cache.name(url: url.absoluteString) else { return nil }
        if !self.cache.exist(name: name, complete: false){
            self.session.dataTask(with: url).resume()
        }
        return name
    }
    public func download(url:URL,callback:@escaping (Data?)->Void){
        guard let name = self.download(url: url) else {callback(nil);return}
        if self.cache.exist(name: name, complete: true){
            callback(self.cache.queryAllData(name: name))
        }else{
            self.observerDownload(name:name) { [weak self] i in
                callback(self?.cache.queryAllData(name: name))
            }
        }
    }
    
    public var cache:CacheContent
    public var notificationCenter = NotificationCenter()
    public var queue:OperationQueue = OperationQueue()
    public init(cache:CacheContent = Cache.shared){
        self.cache = cache
        super.init()
    }
    public static var shared:Downloader = {
        Downloader()
    }()
    public func observerDownload(name:String,callback:@escaping (Any?)->Void){
        var observer:Any?
        observer = self.notificationCenter.addObserver(forName: .DownloadTaskEnd, object: nil, queue: .main) { [weak self] info in
            if info.object as? String == name{
                guard let ob = observer else { return }
                self?.notificationCenter.removeObserver(ob)
                callback(info.object)
            }
        }
    }
    public func hasContent(url:URL)->Bool{
        guard let name = Cache.name(url: url.absoluteString) else { return false }
        return self.cache.exist(name: name, complete: false)
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
public class ImageDownloader{
    public var downloader:Downloader
    
    public init(downloader:Downloader = Downloader.shared){
        self.downloader = downloader
    }
    public func download(url:URL,callback:@escaping (CGImageSource?)->Void){
        self.downloader.download(url: url) { d in
            guard let data = d else { return callback(nil) }
            if let source = CGImageSourceCreateWithData(data as CFData, nil){
                if CGImageSourceGetStatus(source) == .statusComplete{
                    callback(source)
                }else{
                    if let name = Cache.name(url: url.absoluteString){
                        self.downloader.cache.delete(name: name)
                    }
                    callback(nil)
                }
            }else{
                callback(nil)
            }
        }
    }
    
    public func downloadImage(url:URL,callback:@escaping (CGImage?)->Void){
        self.downloadImages(url: url) { imgs in
            callback(imgs.first)
        }
    }
    public func downloadImages(url:URL,callback:@escaping ([CGImage])->Void){
        self.download(url: url) { i in
            guard let imgsource = i else { callback([]);return }
            let count = CGImageSourceGetCount(imgsource)
            if count > 0 {
                CGImageSourceGetType(imgsource)
                let imgs:[CGImage] = (0 ..< count).reduce(into: []) { partialResult, i in
                    guard let img = CGImageSourceCreateImageAtIndex(imgsource, i, nil) else { return }
                    partialResult.append(img)
                }
                callback(imgs)
            }else{
                guard let name =  Cache.name(url: url.absoluteString) else { callback([]);return }
                self.downloader.cache.delete(name:name)
                callback([])
            }
        }
    }
    public func imageSource(url:URL)->CGImageSource?{
        guard let name = Cache.name(url: url.absoluteString) else { return nil }
        guard let data = self.downloader.cache.queryAllData(name: name) else { return nil }
        return CGImageSourceCreateWithData(data as CFData, nil)
    }
    public func image(url:URL)->CGImage?{
        guard let source = self.imageSource(url: url) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
    
    public static let shared:ImageDownloader = ImageDownloader()
}
public class StaticImageDownloader:ImageDownloader{
    public init?(){
    }
    public func downloadImage(url:String,callback:@escaping (CGImage?)->Void){
        guard let u = URL(string: url) else { callback(nil);return }
        self.downloadImage(url: u, callback: callback)
    }
}
