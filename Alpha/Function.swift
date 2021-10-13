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



/// SQL 上下文
public class SQLContext{
    public var ctx:OpaquePointer?
    public var values:UnsafeMutablePointer<OpaquePointer?>?
    public var argc:Int32 = 0
    /// 返回
    /// - Parameter v: 整数
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
    /// 返回
    /// - Parameter v: 整数
    public func ret(v:Int32){
        guard let c = ctx else {
            return
        }
        sqlite3_result_int(c, Int32(v))
    }
    /// 返回
    /// - Parameter v: JSON
    public func ret(v:JSON){
        self.ret(v: v.jsonString)
    }
    /// 返回
    /// - Parameter v: 整数
    public func ret(v:Int64){
        guard let c = ctx else {
            return
        }
        sqlite3_result_int64(c, Int64(v))
    }
    /// 返回
    /// - Parameter v: 字符串
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
    /// 返回
    /// - Parameter v: data
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
    /// 返回
    /// - Parameter v: 浮点数
    public func ret(v:Float){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_double(sc, Double(v))
    }
    /// 返回
    /// - Parameter v: 浮点数
    public func ret(v:Double){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_double(sc, v)
    }
    /// 返回
    ///
    public func ret(){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_null(sc)
    }
    /// 返回错误
    /// - Parameters:
    ///   - error: 错误文本
    ///   - code: 错误码
    public func ret(error:String,code:Int32){
        guard let sc = ctx else {
            return
        }
        sqlite3_result_error(sc, error, Int32(error.utf8.count))
        sqlite3_result_error_code(sc, code)
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func value(index:Int)->Int{
        guard let p = self.valuePointer(index: index) else { return 0}
        if MemoryLayout<Int>.size == 4{
            return Int(sqlite3_value_int(p))
        }else{
            return Int(sqlite3_value_int64(p))
        }
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
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
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func value(index:Int)->Int32{
        guard let p = self.valuePointer(index: index) else { return 0}
        return sqlite3_value_int(p)
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func value(index:Int)->Int64{
        guard let p = self.valuePointer(index: index) else { return 0}
        return sqlite3_value_int64(p)
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func value(index:Int)->Double{
        guard let p = self.valuePointer(index: index) else { return 0}
        return sqlite3_value_double(p)
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func value(index:Int)->Float{
        guard let p = self.valuePointer(index: index) else { return 0}
        return Float(sqlite3_value_double(p))
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func value(index:Int)->String{
        guard let p = self.valuePointer(index: index) else { return ""}
        return String(cString: sqlite3_value_text(p))
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func valueInt(index:Int)->Int{
        guard let p = self.valuePointer(index: index) else { return 0}
        return Int(sqlite3_value_int64(p))
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func valueJSON(index:Int)->JSON?{
        let json = self.valueString(index: index)
        let js = JSON(stringLiteral: json)
        return js
    }
    /// 调用参数
    /// - Parameter index: 参数index
    /// - Returns: 参数
    public func valueString(index:Int)->String{
        let str:String = self.value(index: index)
        return str
    }
    /// 调用参数类型
    /// - Parameter index: 参数index
    /// - Returns: 参数类型
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
    
    /// 函数类型
    public var funtionType:FunctionType{
        .scalar
    }
    /// 创建函数
    /// - Parameters:
    ///   - name: 函数名
    ///   - nArg: 参数个数
    ///   - handle: 函数block
    public init(name:String,nArg:Int32,handle:@escaping CallFunction<Function>) {
        self.name = name
        self.nArg = nArg
        self.call = handle
    }
   
   
}
public class AggregateFunction:Function{
    public let final:FinalFunction<AggregateFunction>
    public let step:CallFunction<AggregateFunction>
    /// 创建函数
    /// - Parameters:
    ///   - name: 函数名
    ///   - nArg: 参数个数
    ///   - step: 迭代函数体
    ///   - final: 结果函数体
    public init(name:String,nArg:Int32,step:@escaping CallFunction<AggregateFunction>,final:@escaping FinalFunction<AggregateFunction>) {
        self.final = final
        self.step = step
        super.init(name: name, nArg: nArg) { ctx, i in
            
        }
    }
    /// 函数类型
    public override var funtionType: FunctionType{
        return .aggregate
    }
    /// 函数上下文创建
    /// - Returns: 上下问对象
    public func aggregateContext<T:AnyObject>(type:T.Type)->T {
        let p = sqlite3_aggregate_context(self.ctx!, Int32(MemoryLayout<T>.size))
        return Unmanaged<T>.fromOpaque(p!).takeUnretainedValue()
    }
    /// 函数上下文创建
    /// - Returns: 上下问对象
    public func aggregateContext<T>(type:T.Type)->UnsafeMutablePointer<T> {
        let p = sqlite3_aggregate_context(self.ctx!, Int32(MemoryLayout<T>.size))
        let struc = (p?.assumingMemoryBound(to: type))!
        return struc
    }
}
extension Database{
    /// 函数时注册
    /// - Parameter function: 函数
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
