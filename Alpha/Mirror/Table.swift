//
//  Table.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3

 
public protocol SQLCode{
    static var tableName:String { get }
    init()
    var columnMap:[(label:String,value:SqlType)] { get }
}
public protocol Value{
    static var type:Database.ResultSet.DBDataType { get }
}
extension Value{
    public func value<T:Value>(type:T.Type)->T?{
        return Self.type == T.type ? self as? T : nil
    }
}

extension Int:Value{
    public static var type: Database.ResultSet.DBDataType{
        .Integer
    }
}
extension String:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Text
    }
}
extension Double:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Float
    }
}
extension Data:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Blob
    }
}
extension Model:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Text
    }
}

@dynamicMemberLookup
public struct SQLResult{
    public var value:[String:Value] = [:]
    
    public subscript(dynamicMember dynamicMember:String)->Value?{
        self.value[dynamicMember]
    }
}

extension SQLResult{
    public static func query<T:Model>(db:Database,req:FetchRequest<T>)throws ->[T]{
        let result = try db.query(sql: req.sql)
        req.doSelectBind(result: result)
        var array:[T] = []
        while (try result.step()){
            var dic:[String:Value] = [:]
            for i in 0 ..< result.columnCount {
                let name = result.columnName(index: i)
                switch result.type(index: Int32(i)) {
                
                case .Integer:
                    let str = result.column(index: Int32(i), type: Int.self).value()
                    dic[name] = str
                    break
                case .Float:
                    let str = result.column(index: Int32(i), type: Double.self).value()
                    dic[name] = str
                    break
                case .Text:
                    let str = result.column(index: Int32(i), type: String.self).value()
                    dic[name] = str
                    break
                case .Blob:
                    let str = result.column(index: Int32(i), type: Data.self).value()
                    dic[name] = str
                    break
                case .Null:
                    break
                }
            }
            array.append(T(result: SQLResult(value: dic)))
        }
        return array
    }
    public static func query(db:Database,modelId:String, model:inout Model) throws {
        let sql = "select * from \(Model.tableName) where modelId=?"
        guard let result = try self.query(db: db, sql: sql,bind: { rs in
            rs.bind(index: 1).bind(value: modelId)
        }).first else { throw NSError(domain: "query nil", code: 0, userInfo: nil) }
        model.load(result: result)
    }
    public static func query(db:Database,sql:String,bind:(Database.ResultSet)->Void)throws ->[SQLResult]{
        let result = try db.query(sql: sql)
        bind(result)
        var array:[SQLResult] = []
        while (try result.step()){
            var dic:[String:Value] = [:]
            for i in 0 ..< result.columnCount {
                let name = result.columnName(index: i)
                switch result.type(index: Int32(i)) {
                
                case .Integer:
                    let str = result.column(index: Int32(i), type: Int.self).value()
                    dic[name] = str
                    break
                case .Float:
                    let str = result.column(index: Int32(i), type: Double.self).value()
                    dic[name] = str
                    break
                case .Text:
                    let str = result.column(index: Int32(i), type: String.self).value()
                    dic[name] = str
                    break
                case .Blob:
                    let str = result.column(index: Int32(i), type: Data.self).value()
                    dic[name] = str
                    break
                case .Null:
                    break
                }
            }
            array.append(SQLResult(value: dic))
        }
        return array
    }
    public static func save<T:Model>(db:Database,model:T) throws {
        if try db.tableExists(name: T.tableName) == false{
            try db.create(obj: model)
        }
        try db.save(model: model)
    }
}


public class Model:NSObject,SQLCode{
    
    public override var debugDescription: String{
        return "\n" + self.result.value.debugDescription
    }
    public required override init() {
        self.modelId = UUID().uuidString
    }
    
    public static var tableName: String{
        return "\(self)".components(separatedBy: ".").last!
    }
    
    @PrimaryKey
    @Column(\Model.modelId)
    @objc public var modelId:String = ""
    var result:SQLResult = SQLResult()
    required public init(modelId:String) {
        self.modelId = modelId
//        self.database = database
        super.init()
//        var a = self
//        try? SQLResult.query(db: database, modelId: modelId, model: &a)
    }
    required public init(result:SQLResult){
        super.init()
        self.load(result: result)
    }
    func load(result:SQLResult){
//        let relateMap = self.relateMap
        for i in result.value {
//            if let relate = relateMap[i.key]{
//                let obj:Model? = class_createInstance(relate, 0) as? Model
//                if obj != nil{
//
//                    try? SQLResult.query(db: database, modelId: i.value as! String, model: &obj!)
//                    obj?.modelId = i.value as! String
//                }
//
//                self.setValue(obj, forKey: i.key)
//            }else{
                self.setValue(i.value, forKey: i.key)
//            }
        }
//        self.database = database
        self.result = result

    }

    public var relateMap:[String:AnyClass]{
        var c:UInt32 = 0
        var result:[String:AnyClass] = [:]
        guard let p = class_copyPropertyList(self.classForCoder, &c) else { return [:] }
        for i in 0 ..< c {
            let property = p.advanced(by: Int(i)).pointee
            guard let a = property_getAttributes(property) else { continue }
            let key = String(cString: property_getName(property))
            
            let att = String(cString: a)
            guard let ctype = att.components(separatedBy: ",").first else { continue }
            if ctype.hasPrefix("T@"){
                let mtype = ctype.components(separatedBy: "\"")[1]
                guard let mp = mtype.cString(using: .utf8) else { continue }
                guard let c = objc_getClass(mp) as? AnyClass else { continue }
                if String(cString: class_getName(class_getSuperclass(c))) == "Alpha.Model"{
                    result[key] = c
                }
            }
        }
        return result
    }
    public var columnMap:[(label:String,value:SqlType)]{
        var c:UInt32 = 0
        var result:[(String,SqlType)] = []
        guard let p = class_copyPropertyList(self.classForCoder, &c) else { return result }
        for i in 0 ..< c {
            let property = p.advanced(by: Int(i)).pointee
            guard let a = property_getAttributes(property) else { continue }
            let key = String(cString: property_getName(property))
            
            let att = String(cString: a)
            guard let ctype = att.components(separatedBy: ",").first else { continue }
            if ctype.hasPrefix("T@"){
                if ctype == "T@\"NSString\""{
                    result.append((key,modelSqlType(sqlType: "TEXT",value: self.value(forKey: key) as? String)))
                } else if ctype == "T@\"NSData\""{
                    result.append((key,modelSqlType(sqlType: "BLOB",value: self.value(forKey: key) as? Data)))
                }else{
//                    let mtype = ctype.components(separatedBy: "\"")[1]
//                    guard let mp = mtype.cString(using: .utf8) else { continue }
//                    guard let c = objc_getClass(mp) as? AnyClass else { continue }
//                    if String(cString: class_getName(class_getSuperclass(c))) == "Alpha.Model"{
//                        if let v = self.value(forKey: key) as? Model{
//                            result.append((key,modelSqlType(sqlType: "TEXT",value:v.modelId)))
//                        }else{
//                            result.append((key,modelSqlType(sqlType: "TEXT",value:nil)))
//                        }
//                    }
                }
            }
            
            if ctype == "Tc" || ctype == "Ts" || ctype == "Ti" || ctype == "Tq"{
                result.append((key,modelSqlType(sqlType: "INTEGER",value: self.value(forKey: key) as! Int )))
            }
            if ctype == "Td" || ctype == "Tf" {
                result.append((key,modelSqlType(sqlType: "FLOAT",value: self.value(forKey: key) as! Double)))
            }
        }
        
        result.append(("modelId",modelSqlType(sqlType: "TEXT",primaryKey:true, value: self.modelId)))
        return result
    }
    public struct modelSqlType:SqlType{
        public var sqlType: String
        
        public var primaryKey: Bool = false
        
        public var remoteTable: String?
        
        public var remoteKey: String?
        
        public var keyName: String?
        
        public var nullable: Bool = true
        
        public var defaultValue: String?
        
        public var onDelete: ForeignKeyAction?
        
        public var onUpdate: ForeignKeyAction?
        
        public var value: OriginValue?
        
        public var path: AnyKeyPath?
        
        
    }
}

