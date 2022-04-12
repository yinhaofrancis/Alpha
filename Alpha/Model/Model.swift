//
//  Model.swift
//  Alpha
//
//  Created by hao yin on 2021/8/31.
//
//
import Foundation
import SQLite3

@dynamicMemberLookup
public struct JSON:CustomStringConvertible,
            ExpressibleByArrayLiteral,
            ExpressibleByDictionaryLiteral,
            ExpressibleByStringLiteral{
    public typealias StringLiteralType = String
    
    public typealias ArrayLiteralElement = Any
    
    public typealias Key = String
    
    public typealias Value = Any
    
    var content:Any?
    
    public var description: String{
        return "\(self.json)"
    }
    
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        var temp = Dictionary<String,Any>()
        for i in elements {
            temp[i.0] = i.1
        }
        self.init(temp)
    }
    
    init(content:Any?){
        self.content = content
    }
    public init (_ json:[String:Any]){
        var temp:[String:Any] = [:]
        for i in json {
            if let dc = i.value as? Dictionary<String,Any>{
                temp[i.key] = JSON(dc)
            }else if let dc = i.value as? Array<Any>{
                temp[i.key] = JSON(dc)
            }else{
                temp[i.key] = JSON(content:i.value)
            }
        }
        self.content = temp
    }
    public init(_ json:Any?){
        if let dc = json as? Dictionary<String,Any>{
            self.init(dc)
        }else if let dc = json as? Array<Any>{
            self.init(dc)
        }else{
            self.init(content:json)
        }
    }
    public init(_ json:[Any]){
        var temp:[Any] = []
        for i in json {
            if let dc = i as? Dictionary<String,Any>{
                temp.append(JSON(dc))
            }else if let dc = i as? Array<Any>{
                temp.append(JSON(dc))
            }else{
                temp.append(JSON(content: i))
            }
        }
        self.content = temp
    }
    public init(_ json:Data){
        do{
            let j = try JSONSerialization.jsonObject(with: json, options: .allowFragments)
            self.init(j)
        }catch{
            let str = String(data: json, encoding: .utf8)
            self.init(content:str)
        }
    }
    public init(stringLiteral json:String){
        guard let data = json.data(using: .utf8) else {
            self.init(content: json)
            return
        }
        self.init(data)
    }
    public subscript(dynamicMember dynamicMember:String)->JSON{
        get{
            self.keyValue(dynamicMember: dynamicMember) ?? JSON(nil)
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: newValue)
        }
    }
    public subscript(dynamicMember dynamicMember:String)->String{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.str() ?? ""
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(content: newValue))
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Any{
        get{
            self.keyValue(dynamicMember: dynamicMember) ?? JSON(nil)
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(newValue))
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Date{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.date() ?? Date(timeIntervalSince1970: 0)
        }
        set{
            let a = DateFormatter()
            a.dateFormat = JSON.dateFormat
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(a.string(from: newValue)))
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Int{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.int() ?? 0
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(newValue))
        }
    }
    public subscript(dynamicMember dynamicMember:String)->UInt64{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.uint64() ?? 0
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(newValue))
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Double{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.double() ?? 0
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(newValue))
        }
        
    }
    public subscript(dynamicMember dynamicMember:String)->Bool{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.bool() ?? false
        }
        set{
            self.setKeyValue(dynamicMember: dynamicMember, json: JSON(newValue))
        }
    }
    public subscript(_ index:Int)->JSON{
        get{
            if let dic = self.content as? Array<JSON>{
                if dic.count > index{
                    return dic[index]
                }
            }
            return JSON(nil)
        }
        set{
            var dic = self.content as? Array<JSON>
            dic?[index] = newValue
            self.content = dic
        }
    }
    public subscript(_ index:Int)->String{
        get{
            self[index].str()
        }
        set{
            self[index] = JSON(newValue)
        }
    }
    public subscript(_ index:Int)->Int{
        get{
            self[index].int()
        }
        set{
            self[index] = JSON(newValue)
        }
    }
    public subscript(_ index:Int)->Double{
        get{
            self[index].double()
        }
        set{
            self[index] = JSON(newValue)
        }
    }
    public subscript(_ index:Int)->Bool{
        get{
            self[index].bool()
        }
        set{
            self[index] = JSON(newValue)
        }
    }
    public subscript(_ index:Int)->Date{
        get{
            self[index].date()
        }
        set{
            self[index] = JSON(newValue)
        }
    }
    public func str()->String{
        if let str = self.content as? String{
            return str
        }else if let db = self.content as? Int{
            return "\(db)"
        }else if let db = self.content as? NSNumber{
            return db.stringValue
        }else if let db = self.content as? Int8{
            return "\(db)"
        }else if let db = self.content as? Int16{
            return "\(db)"
        }else if let db = self.content as? Int32{
            return "\(db)"
        }else if let db = self.content as? Int64{
            return "\(db)"
        }else if let db = self.content as? UInt{
            return "\(db)"
        }else if let db = self.content as? UInt8{
            return "\(db)"
        }else if let db = self.content as? UInt16{
            return "\(db)"
        }else if let db = self.content as? UInt32{
            return "\(db)"
        }else if let db = self.content as? UInt64{
            return "\(db)"
        }else if let db = self.content as? Float{
            return "\(db)"
        }else if let db = self.content as? Double{
            return "\(db)"
        }else if let db = self.content as? JSON{
            return db.jsonString
        }else{
            return ""
        }
    }
    public func keyValue(dynamicMember:String)->JSON?{
        if let dic = self.content as? Dictionary<String,JSON>{
            return dic[dynamicMember]
        }
        return nil
    }
    public mutating func setKeyValue(dynamicMember:String,json:JSON?){
        
        var dic = self.content as? Dictionary<String,JSON>
        if dic != nil{
            dic?[dynamicMember] = json
            self.content = dic
        }
    }
    public func int()->Int{
        if let str = self.content as? String{
            return Int(str) ?? 0
        }else if let db = self.content as? Int{
            return Int(db)
        }else if let db = self.content as? NSNumber{
            return db.intValue
        }else if let db = self.content as? Int8{
            return Int(db)
        }else if let db = self.content as? Int16{
            return Int(db)
        }else if let db = self.content as? Int32{
            return Int(db)
        }else if let db = self.content as? Int64{
            return Int(db)
        }else if let db = self.content as? UInt{
            return Int(db)
        }else if let db = self.content as? UInt8{
            return Int(db)
        }else if let db = self.content as? UInt16{
            return Int(db)
        }else if let db = self.content as? UInt32{
            return Int(db)
        }else if let db = self.content as? UInt64{
            return Int(db)
        }else if let db = self.content as? Float{
            return Int(db)
        }else if let db = self.content as? Double{
            return Int(db)
        }
        return 0
    }
    public func uint64()->UInt64{
        if let str = self.content as? String{
            return UInt64(str) ?? 0
        }else if let db = self.content as? Int{
            return UInt64(db)
        }else if let db = self.content as? NSNumber{
            return db.uint64Value
        }else if let db = self.content as? Int8{
            return UInt64(db)
        }else if let db = self.content as? Int16{
            return UInt64(db)
        }else if let db = self.content as? Int32{
            return UInt64(db)
        }else if let db = self.content as? Int64{
            return UInt64(db)
        }else if let db = self.content as? UInt{
            return UInt64(db)
        }else if let db = self.content as? UInt8{
            return UInt64(db)
        }else if let db = self.content as? UInt16{
            return UInt64(db)
        }else if let db = self.content as? UInt32{
            return UInt64(db)
        }else if let db = self.content as? UInt64{
            return db
        }else if let db = self.content as? Float{
            return UInt64(db)
        }else if let db = self.content as? Double{
            return UInt64(db)
        }
        return 0
    }
    public func double()->Double{
        if let str = self.content as? String{
            return Double(str) ?? 0
        }else if let db = self.content as? Double{
            return Double(db)
        }else if let db = self.content as? NSNumber{
            return db.doubleValue
        }else if let db = self.content as? Int8{
            return Double(db)
        }else if let db = self.content as? Int16{
            return Double(db)
        }else if let db = self.content as? Int32{
            return Double(db)
        }else if let db = self.content as? Int64{
            return Double(db)
        }else if let db = self.content as? UInt{
            return Double(db)
        }else if let db = self.content as? UInt8{
            return Double(db)
        }else if let db = self.content as? UInt16{
            return Double(db)
        }else if let db = self.content as? UInt32{
            return Double(db)
        }else if let db = self.content as? UInt64{
            return Double(db)
        }else if let db = self.content as? Float{
            return Double(db)
        }else if let db = self.content as? Int{
            return Double(db)
        }
        return 0
    }
    public func bool()->Bool{
        if let str = self.content as? String{
            return str == "true"
        }else if let db = self.content as? Double{
            return db != 0
        }else if let db = self.content as? NSNumber{
            return db.boolValue
        }else if let db = self.content as? Int8{
            return db != 0
        }else if let db = self.content as? Int16{
            return db != 0
        }else if let db = self.content as? Int32{
            return db != 0
        }else if let db = self.content as? Int64{
            return db != 0
        }else if let db = self.content as? UInt{
            return db != 0
        }else if let db = self.content as? UInt8{
            return db != 0
        }else if let db = self.content as? UInt16{
            return db != 0
        }else if let db = self.content as? UInt32{
            return db != 0
        }else if let db = self.content as? UInt64{
            return db != 0
        }else if let db = self.content as? Float{
            return db != 0
        }else if let db = self.content as? Int{
            return db != 0
        }
        return false
    }
    public func array()->[JSON]{
        if let str = self.content as? Array<JSON>{
            return str
        }else{
            return []
        }
    }
    public func date()->Date{
        if let str = self.content as? String{
            let a = DateFormatter()
            a.dateFormat = JSON.dateFormat
            return a.date(from: str) ?? Date(timeIntervalSince1970: TimeInterval(str) ?? 0)
        }else if let db = self.content as? Double{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? NSNumber{
            return Date(timeIntervalSince1970: TimeInterval(db.doubleValue))
        }else if let db = self.content as? Int8{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? Int16{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? Int32{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? Int64{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? UInt{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? UInt8{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? UInt16{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? UInt32{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? UInt64{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? Float{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }else if let db = self.content as? Int{
            return Date(timeIntervalSince1970: TimeInterval(db))
        }
        return Date(timeIntervalSince1970: 0)
    }
    public var json:Any{
        if let dc = self.content as? Dictionary<String,JSON>{
            var dic  = Dictionary<String,Any>()
            for i in dc {
                dic[i.key] = i.value.json
            }
            return dic
        }else if let dc = self.content as? Array<JSON>{
            var dic  = Array<Any>()
            for i in dc {
                dic.append(i.json)
            }
            return dic
        }else{
            return self.content ?? "null"
        }
    }
    public var jsonString:String{
        
        if self.content is Dictionary<String,JSON>{
            guard let data = try? JSONSerialization.data(withJSONObject: self.json, options: .fragmentsAllowed) else { return ""}
            return String(data: data, encoding: .utf8) ?? ""
        }else if self.content is Array<JSON>{
            guard let data = try? JSONSerialization.data(withJSONObject: self.json, options: .fragmentsAllowed) else { return ""}
            return String(data: data, encoding: .utf8) ?? ""
        }else{
            return self.str()
        }
    }
    public static var dateFormat:String = "yyyy-MM-dd HH:mm:ss.SSS"
}

extension DB.ResultSet.Bind{
    public func bind(value:T) where T == JSON{
        let jsonStr = value.jsonString
        guard let c = jsonStr.cString(using: .utf8) else {
            sqlite3_bind_null(self.stmt, index)
            return
        }
        let p = UnsafeMutablePointer<CChar>.allocate(capacity: jsonStr.utf8.count)
        memcpy(p, c, jsonStr.utf8.count)
        sqlite3_bind_text(self.stmt, index, p, Int32(jsonStr.utf8.count)) { p in
            p?.deallocate()
        }
    }
}
extension DB.ResultSet.Column{
    public func value()->T where T == JSON{
        let string = String(cString: sqlite3_column_text(self.stmt, self.index)).data(using: .utf8)!
        return JSON(string)
    }
}


extension DB{

    public func insert(jsonName:String,json:JSON) throws {
        do {
            let sql = "insert into \(jsonName) values (?)"
            let rs = try self.query(sql: sql)
            rs.bind(index: 1).bind(value: self.cleanJSON(json: json))
            try rs.step()
            rs.close()
        } catch {
            print(error)
            try self.create(jsonName: jsonName)
            try self.insert(jsonName: jsonName, json: json)
        }
    }
    public func save(jsonName:String,json:JSON) throws{
        let id:Int = json.rowid
        if try self.tableExists(name: jsonName) == false {
            try self.create(jsonName: jsonName)
        }
        if id > 0{
            try self.update(jsonName: jsonName, json: json)
        }else{
            try self.insert(jsonName: jsonName, json: json)
        }
    }
    public func update(jsonName:String,json:JSON) throws {
        try self.update(jsonName: jsonName, current: json, patch: json)
    }
    public func insert(jsonName:String,json:JSON,patch:JSON) throws {
        do {
            let sql = "insert into \(jsonName) values (json_patch(?,?))"
            let rs = try self.query(sql: sql)
            rs.bind(index: 1).bind(value: self.cleanJSON(json: json))
            rs.bind(index: 2).bind(value: self.cleanJSON(json: patch))
            try rs.step()
            rs.close()
        } catch {
            try self.create(jsonName: jsonName)
            try self.insert(jsonName: jsonName, json: json)
        }
    }
    public func update(jsonName:String,current:JSON,patch:JSON) throws{
        let id:Int = current.rowid;
        if id > 0{
            let sql = "update \(jsonName) set json = json_patch(\(jsonName).json,?) where ROWID = ?"
            let rs = try self.query(sql: sql)
            rs.bind(index: 1).bind(value: self.cleanJSON(json: patch))
            rs.bind(index: 2).bind(value: id)
            try rs.step()
            rs.close()
        }else{
           try self.insert(jsonName: jsonName, json: current, patch: patch)
        }
    }
    public func delete(jsonName:String,current:JSON) throws{
        let id:UInt64 = current.rowid
        try self.delete(jsonName: jsonName, rowid: id)
    }
    public func delete(jsonName:String,rowid:UInt64) throws{
        let sql = "delete from \(jsonName) where rowid=\(rowid)"
        try self.exec(sql: sql)
    }
    public func create(jsonName:String) throws{
        let sql = "create table if not exists \(jsonName) (json JSON)"
        try self.exec(sql: sql)
    }
    private func cleanJSON(json:JSON)->JSON{
        var vjson = json
        vjson.content = json.content
        vjson.setKeyValue(dynamicMember: "rowid", json: nil)
        return vjson
    }
    public func query(jsonName:String,condition:Condition? = nil,values:[JSON] = []) throws ->[JSON]{
        try self.query(jsonName: jsonName, conditionStr: condition?.conditionCode, values: values)
    }
    public func query(jsonName:String,keypath:String,condition:Condition? = nil,values:[JSON] = []) throws ->[JSON]{
        try self.query(jsonName: jsonName,keypath: keypath, conditionStr: condition?.conditionCode, values: values)
    }
    public func query(jsonName:String,conditionStr:String?,values:[JSON]) throws ->[JSON]{
        let c = conditionStr == nil ? "where json_valid(json) = 1" : "where \(conditionStr!) and json_valid(json) = 1"
        let sql = "select json_set(json,'$.rowid',rowid) from \(jsonName) " + c
        let rs = try self.query(sql: sql)
        if values.count > 0{
            for i in 1 ..< values.count + 1 {
                rs.bind(index: Int32(i)).bind(value: values[i - 1])
            }
        }
        var result:[JSON] = []
        while(try rs.step()){
            result.append(rs.column(index: 0, type: JSON.self).value())
        }
        rs.close()
        return result
    }
    public func query(jsonName:String,keypath:String,conditionStr:String?,values:[JSON]) throws ->[JSON]{
        let c = conditionStr == nil ? "where json_valid(json) = 1" : "where \(conditionStr!) and json_valid(json) = 1"
        let sql = "select json_extract(json,'$.\(keypath)') from \(jsonName) " + c
        let rs = try self.query(sql: sql)
        if values.count > 0{
            for i in 1 ..< values.count + 1 {
                rs.bind(index: Int32(i)).bind(value: values[i - 1])
            }
        }
        var result:[JSON] = []
        while(try rs.step()){
            result.append(rs.column(index: 0, type: JSON.self).value())
        }
        rs.close()
        return result
    }
    
}


@propertyWrapper
public struct SettingIntKey{
    public var name:String
    public var keys:String
    public var wrappedValue:Int?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first?.int()
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}
@propertyWrapper
public struct SettingStringKey{
    public var name:String
    public var keys:String
    public var wrappedValue:String?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first?.str()
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}
@propertyWrapper
public struct SettingArrayKey{
    public var name:String
    public var keys:String
    public var wrappedValue:[JSON]?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first?.array()
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}
@propertyWrapper
public struct SettingObjectKey{
    public var name:String
    public var keys:String
    public var wrappedValue:JSON?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}
@propertyWrapper
public struct SettingDoubleKey{
    public var name:String
    public var keys:String
    public var wrappedValue:Double?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first?.double()
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}
@propertyWrapper
public struct SettingBoolKey{
    public var name:String
    public var keys:String
    public var wrappedValue:Bool?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first?.bool()
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}
@propertyWrapper
public struct SettingDateKey{
    public var name:String
    public var keys:String
    public var wrappedValue:Date?{
        get {
            return try? Setting.db.query(jsonName: self.name, keypath: self.keys).first?.date()
        }
    }
    public init(name:String,keys:String){
        self.name = name
        self.keys = keys
    }
}


@propertyWrapper
public struct Setting{
    public var name:String
    public static var db:DB = try! Pool.createDb(name: "setting")
    public static var queue:DispatchQueue = DispatchQueue(label: "setting")
    fileprivate func setValue(_ newValue: JSON?) {
        if let js = Setting.keySetting[self.name], let newjs = newValue{
            // update
            var newv = newjs
            let rowid:Int = js.rowid
            newv.rowid = rowid
            try? Setting.db.save(jsonName: self.name, json: newv)
        }else{
            // insert
            let name:String = self.name
            if newValue == nil{
                try? Setting.db.drop(name: name)
            }else{
                try? Setting.db.insert(jsonName: self.name, json: newValue!)
            }
        }
    }
    
    public var wrappedValue:JSON?{
        get{
            self.query(name: name)
        }
        set{
            Setting.queue.sync {
                setValue(newValue)
            }
        }
    }
    public func query(name:String)->JSON?{
        if (Setting.keySetting[self.name] != nil){
            return Setting.keySetting[self.name]
        }else{
            return try? Setting.db.query(jsonName: self.name).first
        }
    }
    public init(name:String) {
        self.name = name
        if Setting.keySetting[name] == nil{
            try? Setting.db.create(jsonName: name)
            Setting.keySetting[name] = self.query(name: name)
        }
    }
    public static var keySetting:Map = Map<String,JSON>()
}
