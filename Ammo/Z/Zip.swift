//
//  Zip.swift
//  Ammo
//
//  Created by wenyang on 2022/6/10.
//

import Foundation

import zlib

public let bufferSize:Int = 1024


public class Deflate{
    public enum Level:Int32{
        case best = 9
        
        case fast = 1
        
        case none = 0
        case `default` = -1
    }
    
    
    private var zStream:z_streamp
    
    public init(level:Level = .default) throws{
        self.zStream = z_streamp.allocate(capacity: 1)
        self.zStream.pointee.zfree = nil
        self.zStream.pointee.zalloc = nil
        self.zStream.pointee.opaque = nil
        guard Z_OK == deflateInit_(self.zStream, level.rawValue, zlibVersion(),Int32(MemoryLayout<z_stream>.size)) else {
            throw NSError(domain: "create deflate error", code: 0)
        }
    }
    
    public func push(data:Data,finish:Bool = false) throws->Data {
        
        let inBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        
        let outBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        
        data.copyBytes(to: inBuffer, count: data.count)
        self.zStream.pointee.avail_in = uInt(data.count)
        self.zStream.pointee.next_in = inBuffer
        var result = Data()
        defer{
            inBuffer.deallocate()
            outBuffer.deallocate()
            if finish{
                deflateEnd(self.zStream);
            }
        }
        repeat{
            self.zStream.pointee.avail_out = uInt(data.count)
            self.zStream.pointee.next_out = outBuffer
            let ret = deflate(self.zStream, finish ? Z_FINISH : Z_NO_FLUSH)
            if ret == Z_STREAM_ERROR{
                throw NSError(domain: "Z_STREAM_ERROR", code: Int(ret))
            }
            result.append(Data(bytes: outBuffer, count: data.count - Int(self.zStream.pointee.avail_out)))
        }while(self.zStream.pointee.avail_out == 0)
        
        return result
    }
    public func reset(){
        deflateReset(self.zStream)
    }
    deinit{
        self.zStream.deallocate()
    }
    
    @available(iOS 13.4, *)
    public class func compress(source:URL,destination:URL) async throws{
        try await Task {
            let fh = try FileHandle(forReadingFrom: source)
            let dh = try FileHandle(forWritingTo: destination)
            var current:Data?
            let def = try Deflate()
            repeat{
                guard let data = try fh.read(upToCount: bufferSize) else { throw NSError(domain: "error", code: 0)}
                current = data
                try dh.write(contentsOf: try def.push(data: data,finish: data.count < bufferSize))
            }while(current != nil && current!.count == bufferSize)
        }.value
    }
}

public class Inflate{

    
    
    private var zStream:z_streamp
    
    public init(){
        self.zStream = z_streamp.allocate(capacity: 1)
        self.zStream.pointee.zfree = nil
        self.zStream.pointee.zalloc = nil
        self.zStream.pointee.opaque = nil
        inflateInit_(self.zStream, zlibVersion(),Int32(MemoryLayout<z_stream>.size))
    }
    
    public func push(data:Data,finish:Bool = false) throws->Data {
        
        let inBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        
        let outBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer{
            inBuffer.deallocate()
            outBuffer.deallocate()
            if finish{
                inflateEnd(self.zStream)
            }
        }
        data.copyBytes(to: inBuffer, count: data.count)
        self.zStream.pointee.avail_in = uInt(data.count)
        self.zStream.pointee.next_in = inBuffer
        var result:Data = Data()
        repeat{
            self.zStream.pointee.avail_out = uInt(data.count)
            self.zStream.pointee.next_out = outBuffer
            let ret = inflate(self.zStream, Z_NO_FLUSH)
            switch(ret){
            case Z_NEED_DICT:
                throw NSError(domain: "error", code: Int(ret))
            case Z_MEM_ERROR:
                throw NSError(domain: "error", code: Int(ret))
            case Z_DATA_ERROR:
                throw NSError(domain: "error", code: Int(ret))
            default:
                break
            }
            result.append(Data(bytes: outBuffer, count: data.count - Int(self.zStream.pointee.avail_out)))
        }while(self.zStream.pointee.avail_out == 0)
        return result
    }
    public func reset(){
        inflateReset(self.zStream)
    }
    deinit{
        self.zStream.deallocate()
    }
    @available(iOS 13.4, *)
    public class func uncompress(source:URL,destination:URL) async throws{
        try await Task {
            let fh = try FileHandle(forReadingFrom: source)
            let dh = try FileHandle(forWritingTo: destination)
            var current:Data?
            let inf = Inflate()
            repeat{
                guard let data = try fh.read(upToCount: bufferSize) else { throw NSError(domain: "error", code: 0)}
                current = data
                try dh.write(contentsOf: inf.push(data: data,finish: data.count < bufferSize))
            }while(current != nil && current!.count == bufferSize)
        }.value
    }
}
