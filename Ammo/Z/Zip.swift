//
//  Zip.swift
//  Ammo
//
//  Created by wenyang on 2022/6/10.
//

import Foundation

import zlib



public class Deflate{
    public enum Level:Int32{
        case best = 9
        
        case fast = 1
        
        case none = 0
        case `default` = -1
    }
    
    
    private var zStream:z_streamp
    
    public init(level:Level) throws{
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
    
    public class func compress(data:Data,level:Level = .default) ->Data?{
        let a:UnsafeMutablePointer<Bytef>? = UnsafeMutablePointer.allocate(capacity: data.count)
        var count:uLongf = uLongf(data.count)
        
        let s = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer{
            s.deallocate()
        }
        data.copyBytes(to: s, count: data.count)
        let ret = compress2(a, &count, s, uLong(data.count),level.rawValue)
        guard Z_OK == ret else { return nil}
        guard let out = a else { return nil }
        return Data(bytesNoCopy: out, count: Int(count), deallocator: .free)
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
    public class func uncompress(data:Data,size:UInt = 1024) ->Data?{
        let a:UnsafeMutablePointer<Bytef>? = UnsafeMutablePointer.allocate(capacity: Int(size))
        var count:uLongf = size
        var sourcelen:uLong = uLong(data.count)
        
        let s = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer{
            s.deallocate()
        }
        data.copyBytes(to: s, count: data.count)
        let ret = uncompress2(a, &count, s, &sourcelen)
        if ret == Z_BUF_ERROR{
            return uncompress(data: data, size: size * 2)
        }
        guard Z_OK == ret else { return nil }
        guard let out = a else { return nil }
        return Data(bytesNoCopy: out, count: Int(count), deallocator: .free)
    }
}
