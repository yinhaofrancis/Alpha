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
public typealias CallFunction<T:Function> = (T,_ argc:Int32)->Void
public typealias FinalFunction<T:Function> = (T)->Void



public class SQLContext{
    public var ctx:OpaquePointer?
    public var values:UnsafeMutablePointer<OpaquePointer?>?
    public var argc:Int32 = 0
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
        sqlite3_result_text(sc, p, Int32(v.utf8.count)) { p in
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
    public func value(index:Int)->Int{
        guard let p = self.valuePointer(index: index) else { return 0}
        if MemoryLayout<Int>.size == 4{
            return Int(sqlite3_value_int(p))
        }else{
            return Int(sqlite3_value_int64(p))
        }
    }
    public func valuePointer(index:Int)->OpaquePointer?{
        guard let vs = self.values else { return nil }
        guard let p = vs.advanced(by: index).pointee else { return nil }
        return p
    }
    @available(iOS 12.0, *)
    public func valueNoChange(index:Int){
        guard let p = self.valuePointer(index: index) else { return }
        sqlite3_value_nochange(p)
    }
    public func value(index:Int)->Int32{
        guard let p = self.valuePointer(index: index) else { return 0}
        return sqlite3_value_int(p)
    }
    public func value(index:Int)->Int64{
        guard let p = self.valuePointer(index: index) else { return 0}
        return sqlite3_value_int64(p)
    }
    public func value(index:Int)->Double{
        guard let p = self.valuePointer(index: index) else { return 0}
        return sqlite3_value_double(p)
    }
    public func value(index:Int)->Float{
        guard let p = self.valuePointer(index: index) else { return 0}
        return Float(sqlite3_value_double(p))
    }
    public func value(index:Int)->String{
        guard let p = self.valuePointer(index: index) else { return ""}
        return String(cString: sqlite3_value_text(p))
    }
    public func valueType(index:Int)->ContextValueType{
        guard let p = self.valuePointer(index: index) else { return .Null}
        let type = sqlite3_value_type(p)
        switch type {
        case SQLITE_TEXT:
            return .Text
        case SQLITE_INTEGER:
            return .Int
        case SQLITE_BLOB:
            return .Blob
        case SQLITE_FLOAT:
            return .Float
        default:
            return .Null
        }
    }
    public enum ContextValueType:Int32{
        case Null
        case Float
        case Int
        case Blob
        case Text
    }
}

public class Function:SQLContext{
    
    public let name:String
    public let nArg:Int32
    
    
    public weak var db:Database?
    public let call:CallFunction<Function>
    
    public var funtionType:FunctionType{
        .scalar
    }
    public init(name:String,nArg:Int32,handle:@escaping CallFunction<Function>) {
        self.name = name
        self.nArg = nArg
        self.call = handle
    }
   
   
}
public class AggregateFunction:Function{
    public let final:FinalFunction<AggregateFunction>
    public let step:CallFunction<AggregateFunction>
    public init(name:String,nArg:Int32,step:@escaping CallFunction<AggregateFunction>,final:@escaping FinalFunction<AggregateFunction>) {
        self.final = final
        self.step = step
        super.init(name: name, nArg: nArg) { ctx, i in
            
        }
    }
    public override var funtionType: FunctionType{
        return .aggregate
    }
    public func aggregateContext<T:AnyObject>(type:T.Type)->T {
        let p = sqlite3_aggregate_context(self.ctx!, Int32(MemoryLayout<T>.size))
        return Unmanaged<T>.fromOpaque(p!).takeUnretainedValue()
    }
    public func aggregateContext<T>(type:T.Type)->UnsafeMutablePointer<T> {
        let p = sqlite3_aggregate_context(self.ctx!, Int32(MemoryLayout<T>.size))
        let struc = (p?.assumingMemoryBound(to: type))!
        return struc
    }
}
extension Database{
    public func addFunction(function:Function){
        function.db = self
        if function.funtionType == .aggregate{
            sqlite3_create_function(self.sqlite!, function.name, function.nArg, SQLITE_UTF8, Unmanaged.passRetained(function).toOpaque(), nil) { ctx, i, ret in
                let call = Unmanaged<AggregateFunction>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
                call.ctx = ctx
                call.values = ret
                call.step(call,i)
            } _: { ctx in
                let call = Unmanaged<AggregateFunction>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
                call.ctx = ctx
                call.final(call)
            }
        }else{
            sqlite3_create_function(self.sqlite!, function.name, function.nArg, SQLITE_UTF8, Unmanaged.passRetained(function).toOpaque(), { ctx, i, ret in
                let call = Unmanaged<Function>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
                call.ctx = ctx
                call.values = ret
                call.call(call,i)
            }, nil, nil)
        }
        
    }
}
