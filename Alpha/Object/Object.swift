//
//  Object.swift
//  Alpha
//
//  Created by hao yin on 2021/9/9.
//

import Foundation

public struct DataMode: OptionSet {
    public let rawValue: UInt8
    public var defaultValue:String?
    public static let none = DataMode([])
    public static let primary = DataMode(rawValue: 1 << 0)
    public static let notnull = DataMode(rawValue: 1 << 1)
    public static let unique = DataMode(rawValue: 1 << 2)
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
public enum DataTypeDef {
    case integer
    case double
    case text
    case blob
    case object
    case json
    case null
    public var define:String{
        switch self {
        
        case .integer:
            return "INTEGER"
        case .double:
            return "REAL"
        case .text:
            return "TEXT"
        case .blob:
            return "BLOB"
        case .object:
            return "TEXT"
        case .json:
            return "JSON"
        case .null:
            return "null"
        }
    }
}
public protocol DataType{
    static func define()->DataTypeDef
    func bind(rs:DB.ResultSet,key:String)
    func bind(rs:DB.ResultSet,index:Int32)
}
extension Optional:DataType where Wrapped == DataType {
    public static func define() -> DataTypeDef {
        .null
    }
    public func bind(rs: DB.ResultSet, key: String) {
        switch self {
        case .none:
            return rs.bindNull(name: key)
        case let .some(v):
            return v.bind(rs: rs, key: key)
        }
    }
        
    public func bind(rs: DB.ResultSet, index: Int32) {
        switch self {
        case .none:
            return rs.bindNull(index: index)
        case let .some(v):
            return v.bind(rs: rs, index:index)
        }
    }
}
extension String:DataType{
    public static func define() -> DataTypeDef {
        return .text
    }
    
    public func bind(rs: DB.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    public func bind(rs: DB.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
}
extension Int:DataType{
    public static func define() -> DataTypeDef {
        return .integer
    }
    

    public func bind(rs: DB.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    public func bind(rs: DB.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
}
extension Double:DataType{
    public static func define() -> DataTypeDef {
        return .double
    }
    
   
    public func bind(rs: DB.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }

    public func bind(rs: DB.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
}
extension Data:DataType{
    public static func define() -> DataTypeDef {
        return .blob
    }

    public func bind(rs: DB.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self)
    }
    
    public func bind(rs: DB.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self)
    }
}

public class JSONType:NSObject,DataType{
    public var json:JSON
    public init(json:JSON){
        self.json = json
        super.init()
    }
    public override init(){
        self.json = JSON(nil)
        super.init()
    }
    public static func define() -> DataTypeDef {
        .json
    }
    
    public func bind(rs: DB.ResultSet, key: String) {
        if self.json.content == nil{
            rs.bindNull(name: key)
        }else{
            rs.bind(name: key)?.bind(value: self.json)
        }
        
    }
    
    public func bind(rs: DB.ResultSet, index: Int32) {
        if self.json.content == nil{
            rs.bindNull(index: index)
        }else{
            rs.bind(index: index).bind(value: self.json)
        }
    }
    public init(json:Dictionary<String,Any>){
        self.json = JSON(json)
    }
    public var JSONString:String{
        self.json.jsonString
    }
    
}

public protocol ColDef{
    var mode:DataMode { get  }
    var define:DataType { get }
    var readOnly:Bool { get }
    var typeDef:DataTypeDef { get }
}
extension ColDef{
    public var defineCode:String{
        return self.typeDef.define + "\(self.mode.contains(.unique) ? " unique " : "")" + "\(self.mode.contains(.notnull) ? " not null " : "")" + "\(self.mode.defaultValue == nil ? "" : " default \(self.mode.defaultValue!) ")"
    }
}
struct InnerDef:ColDef {
    var readOnly: Bool
    
    var typeDef: DataTypeDef

    var mode: DataMode
    
    var define: DataType
}
@propertyWrapper
public struct Col<T:DataType>:ColDef{
    public var readOnly: Bool = false
    
    public var typeDef: DataTypeDef{
        return T.define()
    }
    
    public var define: DataType{
        return self.inner
    }
    public var mode:DataMode
    private var inner:T
    public var wrappedValue:T{
        get{
            if let ob = self.inner as? Object {
                ob.context?.query(objct: ob)
            }
            return self.inner
        }
        set{
            self.inner = newValue
        }
    }
    public init(wrappedValue:T,_ mode:DataMode = [.none],_ defaultValue:String? = nil) {
        self.inner = wrappedValue
        self.mode = mode
        self.mode.defaultValue = defaultValue
    }
}

@propertyWrapper
public struct NullableCol<T:DataType>:ColDef{
    
    public var readOnly: Bool = false
    
    public var typeDef: DataTypeDef{
        T.define()
    }
    public var define: DataType{
        return self.inner ?? nil
    }
    public var mode:DataMode
    private var inner:T?
    public var wrappedValue:T?{
        get{
            if let objct = inner as? Object{
                objct.context?.query(objct: objct)
            }
            return self.inner
        }
        set{
            self.inner = newValue
        }
    }
    public init(wrappedValue:T?,_ mode:DataMode = [.none],_ defaultValue:String? = nil) {
        self.inner = wrappedValue
        self.mode = mode
        self.mode.defaultValue = defaultValue
    }
}
@propertyWrapper
public struct ReadOnlyCol<T:DataType>:ColDef{
    
    public var readOnly: Bool = true
    
    public var typeDef: DataTypeDef{
        T.define()
    }
    public var define: DataType{
        return self.inner ?? nil
    }
    public var mode:DataMode
    private var inner:T?
    public var wrappedValue:T?{
        get{
            if let objct = inner as? Object{
                objct.context?.query(objct: objct)
            }
            return self.inner
        }
        set{
            self.inner = newValue
        }
    }
    public init(wrappedValue:T?) {
        self.inner = wrappedValue
        self.mode = .none
        self.mode.defaultValue = nil
    }
}

@objcMembers public class Object:NSObject,DataType{
    public static func define() -> DataTypeDef {
        return .object
    }
    public func classOfCollume(name:String)->AnyClass?{
        guard let p = class_getProperty(self.classForCoder, name) else { return nil }
        guard let a = property_copyAttributeValue(p, "T") else { return nil }
        let string = String(cString: a).components(separatedBy: "\"")
        if string.count == 3{
            return NSClassFromString(string[1])
        }
        return nil
    }
    public var objects:[Object]{
        self.objectKeyCol.compactMap { i in
            self.value(forKey: i.key) as? Object
        }
    }
    public func bind(rs: DB.ResultSet, key: String) {
        rs.bind(name: key)?.bind(value: self.objectId)
        try? self.queryObject(db: rs.db)
    }
    
    public func colume(rs: DB.ResultSet, key: String) {
        let name = rs.index(paramName: key)
        self.objectId = rs.column(index: name, type: String.self).value()
    }
    
    public func bind(rs: DB.ResultSet, index: Int32) {
        rs.bind(index: index).bind(value: self.objectId)
    }
    
    public func colume(rs: DB.ResultSet, index: Int32) {
        self.objectId = rs.column(index: index, type: String.self).value()
        try? self.queryObject(db: rs.db)
    }
    public weak var context:Context?{
        didSet{
            for i in self.objects{
                i.context = self.context
            }
        }
    }
    public var objectId:String = UUID().uuidString
    public var name:String{
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
    public var keyCol:[String:ColDef]{
        return Object.classKeyWriteCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public var keyQueryCol:[String:ColDef]{
        return Object.classKeyQueryCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public var primaryKeyCol:[String:ColDef]{
        return Object.classKeyPrimaryCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public var normalKeyCol:[String:ColDef]{
        return Object.classKeyNormalCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    public var objectKeyCol:[String:ColDef]{
        return Object.classKeyObjectCol(cls: Self.self,mirror: Mirror(reflecting: self))
    }
    private static func classKeyCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        var c:UInt32 = 0
        if cls == Self.self{
            guard let v = mirror.children.filter({ i in
                i.label == "objectId"
            }).first?.value else { return [:]}
            return ["objectId":InnerDef(readOnly: false, typeDef: .text, mode: [.notnull,.unique], define: v as! String)]
        }
        let propertys = class_copyPropertyList(cls, &c)
        let km = mirror.children.reduce(into: [:]) { r, kv in
            guard let label = kv.label else { return }
            r[label] = kv.value
        }
        var keymap:[String:ColDef]
        if let sc = cls.superclass() , let sm = mirror.superclassMirror{
            keymap = self.classKeyCol(cls: sc, mirror: sm)
        }else{
            keymap = [:]
        }
        for i in 0 ..< c{
            guard let p = propertys?.advanced(by: Int(i)).pointee else{
                continue
            }
            let name = String(cString: property_getName(p))
            guard let type = property_copyAttributeValue(p, "T") else { continue }
            let pro = String(cString:type)
            if let wrapInfo = km["_" + name]{
                keymap[name] = wrapInfo as? ColDef
            }else{
                if keymap[name] != nil{
                    if pro == "c" || pro == "s" || pro == "i" || pro == "q" || pro == "C" || pro == "S" || pro == "I" || pro == "Q"{
                        
                        keymap[name] = InnerDef(readOnly: false, typeDef: .integer, mode: .none, define: (self.value(forKey: name) as! NSNumber).intValue)
                    }else if pro == "f" || pro == "d"{
                        keymap[name] = InnerDef(readOnly: false, typeDef: .double, mode: .none, define: (self.value(forKey: name) as! NSNumber).doubleValue)
                    }else if pro == "NSData"{
                        keymap[name] = InnerDef(readOnly: false, typeDef: .object, mode: .none, define:  self.value(forKey: name) as! Data)
                    }else{
                        keymap[name] = InnerDef(readOnly: false, typeDef: .object, mode: .none, define: self.value(forKey: name) as! Object)
                    }
                }
            }
            type.deallocate()
        }
        propertys?.deallocate()
        return keymap
    }
    public static func classKeyPrimaryCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            i.value.mode == .primary
        }
    }
    
    public static func classKeyQueryCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            return true
        }
    }
    public static func classKeyWriteCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            i.value.readOnly == false
        }
    }
    public static func classKeyNormalCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            i.value.mode != .primary && i.value.readOnly == false
        }
    }
    public static func classKeyObjectCol(cls:AnyClass,mirror:Mirror)->[String:ColDef]{
        self.classKeyCol(cls: cls, mirror: mirror).filter { i in
            i.value.typeDef == .object && i.value.readOnly == false
        }
    }
    public var insertCode:String{
        let keys = self.keyCol.keys
        let v = keys.map { i in "@" + i }.joined(separator: ",")
        let a = "insert into `\(self.name)` (" + keys.joined(separator: ",") + ") values " + "(" + v + ")"
        return a
    }
    public var condition:String{
        let keys = self.primaryKeyCol.keys
        if keys.count == 0{
            return "objectId=@objectId"
        }else{
            return keys.map{$0 + "=" + "@" + $0}.joined(separator: " and ")
        }
        
    }
    public var updateCode:String{
        let keys = self.keyCol.keys
        return "update `\(self.name)` set " + keys.map { i in
            "\(i)=@\(i)"
        }.joined(separator: ",") + " where " + self.condition
    }
    public var createCode:String{
        let kcm = self.keyCol.map { i in
            i.key + " " + i.value.defineCode
        }
        let pk = self.primaryKeyCol.keys.count > 0 ? ["primary key(" + self.primaryKeyCol.keys.joined(separator: ",") + ")"] : []
        let kmp = (kcm + pk).joined(separator: ",")
        let sql = "create table if not exists`\(self.name)`" + "(\(kmp))"
        return sql
    }
    public var deleteCode:String{
        return "delete from `\(self.name)` where " + self.condition
    }
    public var selectCode:String{
        return "select * from `\(self.name)` where " + self.condition
    }
    public var selectObjectCode:String{
        return "select * from `\(self.name)` where objectId = \(self.objectId)"
    }
    public func result(rs:DB.ResultSet) throws {
        let kv = self.keyQueryCol
        for i in 0 ..< rs.columnCount{
            let name = rs.columnName(index: i)
            if rs.type(index: Int32(i)) == .Null{
                self.setValue(nil, forKey: name)
                continue
            }
            if(name == "objectId"){
                let v = rs.column(index: Int32(i), type: String.self).value()
                self.setValue(v, forKey: name)
                continue
            }
            guard let define = kv[name]?.typeDef else { continue }
            switch define {
            case .integer:
                let v = rs.column(index: Int32(i), type: Int.self).value()
                self.setValue(v, forKey: name)
                break
            case .double:
                let v = rs.column(index: Int32(i), type: Double.self).value()
                self.setValue(v, forKey: name)
                break
            case .text:
                let v = rs.column(index: Int32(i), type: String.self).value()
                self.setValue(v, forKey: name)
                break
            case .blob:
                let v = rs.column(index: Int32(i), type: Data.self).value()
                self.setValue(v, forKey: name)
                break
            case .object:
                let v = rs.column(index: Int32(i), type: String.self).value()
                let obj:Object = class_createInstance(self.classOfCollume(name: name), 0) as! Object
                obj.objectId = v
                self.setValue(obj, forKey: name)
                break
            case .null:
                break
            case .json:
                let json = rs.column(index: Int32(i), type: String.self).value()
                self.setValue(JSONType(json: JSON(json)), forKey: name)
            }
        }
    }

    public func bind(rs:DB.ResultSet){
        for i in self.keyCol {
            i.value.define.bind(rs: rs, key: "@" + i.key)
        }
    }
    public func checkObject(db:DB) throws {
        try self.create(db: db)
        for i in self.objectKeyCol{
            let cls: AnyClass? = self.classOfCollume(name: i.key)
            let inst = class_createInstance(cls, 0) as! Object
            try inst.create(db: db)
        }
    }
    func writeDataCode(db:DB,sql:String) throws {
        
        let rs = try db.query(sql: sql)
        self.bind(rs: rs)
        try rs.step()
        rs.close()
    }
    public func queryModel<T:Object>(db:DB,type:T.Type,con:Condition? = nil) throws ->[T] {
        let sql = "select * from \(T.init().name)" + (con == nil ? "" : " where \(con!.conditionCode)")
        let rs = try db.query(sql: sql)
        self.bind(rs: rs)
        var res:[T] = []
        while try rs.step(){
            let obj = T()
            try obj.result(rs: rs)
            res.append(obj)
        }
        rs.close()
        return res
    }
    func readDataModel<T:Object>(db:DB,sql:String,object: inout T) throws {
        let rs = try db.query(sql: sql)
        self.bind(rs: rs)
        if try rs.step() {
            try object.result(rs: rs)
        }
        rs.close()
    }
    public func insert(db:DB) throws{
        try autoreleasepool {
            try self.writeDataCode(db: db, sql: self.insertCode)
            for i in self.objectKeyCol{
                guard let q = i.value.define as? Object else { throw NSError(domain: "\(self) \(i.key) save error", code: 0, userInfo: nil)}
                try q.save(db: db)
            }
        }
    }
    public func update(db:DB) throws{
        try autoreleasepool {
            try self.writeDataCode(db: db, sql: self.updateCode)
            for i in self.objectKeyCol{
                let q = self.value(forKey: i.key) as! Object
                try q.save(db: db)
            }
        }
    }
    public func save(db:DB) throws{
        do {
            try self.insert(db: db)
        }catch{
            try self.update(db: db)
        }
    }
    public func delete(db:DB) throws{
        try autoreleasepool {
            try self.writeDataCode(db: db, sql: self.deleteCode)
        }
    }
    public func query(db:DB) throws{
        try autoreleasepool {
            var a = self
            try self.readDataModel(db: db, sql: self.selectCode, object: &a)
        }
    }
    public func queryObject(db:DB) throws{
        try autoreleasepool {
            var a = self
            try self.readDataModel(db: db, sql: self.selectCode, object: &a)
        }
    }
    public func create(db:DB) throws{
        try autoreleasepool {
            if try db.tableExists(name: self.name) == false{
                try db.exec(sql: self.createCode)
                return
            }
            for i in try self.newkey(db: db){
                guard let def = self.keyCol[i]?.defineCode else { continue }
                try db.addColumn(name: self.name, columeName: i, typedef: def)
            }
        
            if try self.oldKey(db: db).count > 0{
                try db.alterTableName(name: self.name, newName: self.name + "_tmp")
                try db.exec(sql: self.createCode)
                let tmps = try db.tableInfo(name: self.name + "_tmp").keys
                let new = self.keyCol.keys
                let copyCol = tmps.filter({new.contains($0)})
                try db.copyTable(to: self.name, from: self.name + "_tmp", keys:copyCol)
                try db.drop(name:self.name + "_tmp")
        }
        }
    }
    public func newkey(db:DB) throws ->[String]{
        let old = try db.tableInfo(name: self.name).keys
        return self.keyCol.keys.filter { i in
            old.contains(i) == false
        }
    }
    public func oldKey(db:DB) throws ->[String]{
        let old = try db.tableInfo(name: self.name).keys
        let new = self.keyCol.keys
        return old.filter { i in
            new.contains(i) == false
        }
    }
    public required override init() {
        super.init()
    }
}
public struct Page{
    public let offset:Int32
    public let limit:Int32
}
public enum Order {
    case asc(String)
    case desc(String)
    public var code:String{
        switch self {
        
        case let .asc(a):
            return "`\(a)` ASC"
        case let .desc(a):
            return "`\(a)` DESC"
        }
    }
}
public enum FetchKey{
    case count(String)
    case max(String)
    case min(String)
    case key(ConditionKey)
    case all
    
    public var keyString:String{
        switch self{
     
        case let .count(c):
            return "count(\(c))"
        case let .max(c):
            return "max(\(c))"
        case let .min(c):
            return "min(\(c))"
        case let .key(ck):
            return ck.key
        case .all:
            return "*"
        }
    }
    public static func +(lk:FetchKey,rk:FetchKey)->FetchKey{
        .key(ConditionKey(key: lk.keyString + "," + rk.keyString))
    }
}
public class ObjectRequest<T:Object>{
    let sql:String
    public init(table:String,key:FetchKey = .all,condition:Condition? = nil ,page:Page? = nil,order:[Order] = []){
        self.sql = "select \(key.keyString) from `\(table)`" + ((condition?.conditionCode.count ?? 0) > 0 ? (" where " + condition!.conditionCode) : "") + (order.count > 0 ? " order by" + order.map({$0.code}).joined(separator: ",") : "") + (page == nil ? "" : " LIMIT \(page!.limit) OFFSET \(page!.offset)")
    }
    public func query(db:DB,valueMap:[String:DataType] = [:]) throws ->[T]{
        let rs = try db.query(sql: sql)
        for i in valueMap {
            i.value.bind(rs: rs, key: i.key)
        }
        var result:[T] = []
        while try rs.step() {
            let a = T()
            try a.result(rs: rs)
            result.append(a)
        }
        return result
    }
}

@propertyWrapper
public class Request<T:Object>{
    private var db:Pool{
        return Pool.default
    }
    public var valueMap:[String:DataType]
    public var request:ObjectRequest<T>
    private var innerValue:[T]?
    public var wrappedValue:[T]{
        
        if let temp = innerValue{
            return temp
        }else{
            self.query()
            return innerValue ?? []
        }
        
    }
    public init(vm:[String:DataType] = [:],request:ObjectRequest<T>){
        self.request = request
        self.valueMap = vm
    }
    public var projectedValue:Request{
        return self
    }
    public func add(object:T){
        self.db.writeSync { db in
            do{
                try object.save(db: db)
            }catch{
                try object.create(db: db)
                try object.save(db: db)
            }
        }
        self.query()
    }
    private func query(){
        self.db.readSync { db in
            self.innerValue = try self.request.query(db: db, valueMap: self.valueMap)
        }
    }
}

@propertyWrapper
public class JSONRequest{
    private var db:Pool{
        return Pool.default
    }
    public var keypath:String?
    public var key:String
    private var inner:[JSON]?
    public var wrappedValue:[JSON]{
        if let jsons = self.inner{
            return jsons
        }
        self.query()
        return inner ?? []
    }
    public init(key:String,keypath:String? = nil){
        self.key = key
        self.keypath = keypath
    }
    public var projectedValue:JSONRequest{
        return self
    }
    private func query(){
        self.db.readSync { db in
            if let ky = self.keypath{
                self.inner = try db.query(jsonName: self.key, keypath: ky)
            }else{
                self.inner = try db.query(jsonName: self.key)
            }
        }
    }
    public func add(json:JSON){
        self.db.writeSync { [weak self ]db in
            guard let ws = self else { return }
            
            try db.save(jsonName: ws.key, json: json)
        }
        self.query()
    }
}
