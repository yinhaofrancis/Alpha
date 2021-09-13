//
//  Function.swift
//  Alpha
//
//  Created by hao yin on 2021/7/28.
//

import Foundation
import SQLite3

public enum FunctionType{
    case scalar
    case aggregate
}

public class Function{
    public let name:String
    public let nArg:Int32
    public var ctx:OpaquePointer?
    public let call:(Function,Int32,OpaquePointer?)->Void
    
    public var funtionType:FunctionType{
        .scalar
    }
    public init(name:String,nArg:Int32,handle:@escaping (Function,Int32,OpaquePointer?)->Void) {
        self.name = name
        self.nArg = nArg
        self.call = handle
    }
    public func ret(v:Int){
        guard let c = ctx else {
            return
        }
        if MemoryLayout.size(ofValue: v) == 4{
            sqlite3_result_int(c, Int32(v))
        }else{
            sqlite3_result_int64(c, Int64(v))
        }
        
    }
    public func ret(v:Int32){
        guard let c = ctx else {
            return
        }
        sqlite3_result_int(c, Int32(v))
    }
    public func ret(v:Int64){
        guard let c = ctx else {
            return
        }
        sqlite3_result_int64(c, Int64(v))
    }
    public func ret(v:String){
        guard let sc = ctx else {
            return
        }
        guard let c = v.cString(using: .utf8) else {
            sqlite3_result_null(sc)
            return
        }
        let p = UnsafeMutablePointer<CChar>.allocate(capacity: v.utf8.count)
        memcpy(p, c, v.utf8.count)
        sqlite3_result_text(sc, v.cString(using: .utf8), Int32(v.utf8.count)) { p in
            p?.deallocate()
        }
    }
    public func ret(v:Data){
        guard let sc = ctx else {
            return
        }
        let pointer = sqlite3_malloc(Int32(v.count))
        let buffer = UnsafeMutableRawBufferPointer(start: pointer, count: v.count)
        v.copyBytes(to: buffer, count: v.count)
        sqlite3_result_blob(sc, pointer, Int32(v.count)) { p in
            sqlite3_free(p)
        }
    }
    public func ret(v:Float){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_double(sc, Double(v))
    }
    public func ret(v:Double){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_double(sc, v)
    }
    public func ret(){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_null(sc)
    }
    public func ret(error:String,code:Int32){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_error(sc, error, Int32(error.utf8.count))
        sqlite3_result_error_code(sc, code)
    }
    public func value(value:OpaquePointer)->Int{
        if MemoryLayout<Int>.size == 4{
            return Int(sqlite3_value_int(value))
        }else{
            return Int(sqlite3_value_int64(value))
        }
    }
    @available(iOS 12.0, *)
    public func valueNoChange(value:OpaquePointer){
        sqlite3_value_nochange(value)
    }
    public func value(value:OpaquePointer)->Int32{
        return sqlite3_value_int(value)
    }
    public func value(value:OpaquePointer)->Int64{
        return sqlite3_value_int64(value)
    }
    public func value(value:OpaquePointer)->Double{
        return sqlite3_value_double(value)
    }
    public func value(value:OpaquePointer)->Float{
        return Float(sqlite3_value_double(value))
    }
    public func value(value:OpaquePointer)->String{
        return String(cString: sqlite3_value_text(value))
    }
}
public class AggregateFunction:Function{
    public let final:(Function)->Void
    public init(name:String,nArg:Int32,step:@escaping (Function,Int32,OpaquePointer?)->Void,final:@escaping (Function)->Void) {
        self.final = final
        super.init(name: name, nArg: nArg, handle: step)
    }
    public override var funtionType: FunctionType{
        return .aggregate
    }
    public func aggregateContext<T:AnyObject>(type:T.Type)->T {
        let p = sqlite3_aggregate_context(self.ctx!, Int32(MemoryLayout<T>.size))
        return Unmanaged<T>.fromOpaque(p!).takeUnretainedValue()
    }
    public func aggregateContext<T>(type:T.Type)->T {
        let p = sqlite3_aggregate_context(self.ctx!, Int32(MemoryLayout<T>.size))
        let struc = p?.assumingMemoryBound(to: type).pointee
        return struc!
    }
}
extension Database{
    public func addScalarFunction(function:Function){
        
        if function.funtionType == .aggregate{
            sqlite3_create_function(self.sqlite!, function.name, function.nArg, SQLITE_UTF8, Unmanaged.passRetained(function).toOpaque(), nil) { ctx, i, ret in
                let call = Unmanaged<AggregateFunction>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
                call.ctx = ctx
                call.call(call,i,ret?.pointee)
            } _: { ctx in
                let call = Unmanaged<AggregateFunction>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
                call.ctx = ctx
                call.final(call)
            }
        }else{
            sqlite3_create_function(self.sqlite!, function.name, function.nArg, SQLITE_UTF8, Unmanaged.passUnretained(function).toOpaque(), { ctx, i, ret in
                let call = Unmanaged<Function>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
                call.ctx = ctx
                call.call(call,i,ret?.pointee)
            }, nil, nil)
        }
        
    }
}
