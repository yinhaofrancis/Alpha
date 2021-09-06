//
//  Model.swift
//  Alpha
//
//  Created by hao yin on 2021/8/31.
//
//
import Foundation


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
    
    public init(content:Any?){
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
    public init(content:String){
        self.content = content
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
    public subscript(dynamicMember dynamicMember:String)->Int{
        get{
            self.keyValue(dynamicMember: dynamicMember)?.int() ?? 0
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
        if let dic = self.content as? Array<JSON>{
            if dic.count > index{
                return dic[index]
            }
        }
        return JSON(nil)
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
        dic?[dynamicMember] = json
        self.content = dic
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
    public static var dateFormat:String = "yyyy-mm-dd HH:mm:ss"
}
extension Database{
    func insert(_ dic: [String : JSON], _ name: String) throws {
        do {
            let keys = dic.keys.joined(separator: ",")
            let place = dic.keys.map({"@"+$0}).joined(separator: ",")
            let sql  = "insert into \(name) (\(keys)) values (\(place)"
            let r = try self.query(sql: sql)
            for i in dic {
                r.bind(name: i.key)?.bind(value: i.value.jsonString)
            }
            try r.step()
            r.close()
        } catch {
            try self.create(name, dic)
            let keys = dic.keys.joined(separator: ",")
            let place = dic.keys.map({"@"+$0}).joined(separator: ",")
            let sql  = "insert into \(name) (\(keys)) values (\(place))"
            let r = try self.query(sql: sql)
            for i in dic {
                r.bind(name: "@"+i.key)?.bind(value: i.value.jsonString)
            }
            try r.step()
            r.close()
        }
        
    }
    
    public func insert(_ name: String, _ json: JSON) throws {
        if let dic = json.content as? Dictionary<String,JSON>{
            try insert(dic, name)
        }else if let dic = json.content as? Array<Dictionary<String,JSON>>{
            for i in dic {
                try insert(i, name)
            }
        }else{
            throw NSError(domain: "JSON is not object", code: 0, userInfo: nil)
        }
    }
    func update(_ name:String,_ rowid:Int,_ json: [String : JSON]) throws {
        let set:[String] = json.reduce(into: []) { r, c in
            if c.key != "rowid"{
                r.append("\(c.key)=@\(c.key)")
            }
        }
        let sql = "update \(name) set \(set.joined(separator: ",")) where `rowid`=@rowid"
        let rs = try self.query(sql: sql)
        for i in json {
            if (i.key != "rowid"){
                
                rs.bind(name: "@"+i.key)?.bind(value: i.value.jsonString)
            }else{
                print(i.key,i.value.int())
                rs.bind(name: "@"+i.key)?.bind(value: i.value.int())
            }
        }
        try rs.step()
        rs.close()
    }
    public func update(_ name:String,_ rowid:Int,_ json: JSON) throws {
        if let dic = json.content as? Dictionary<String,JSON>{
            try self.update(name,rowid, dic)
            return
        }
        if let dic = json.content as? Array<Dictionary<String,JSON>>{
            for i in dic {
                try self.update(name, rowid, i)
            }
            return
        }
        throw NSError(domain: "update json", code: 0, userInfo: nil)
    }
    public func save(_ name:String,_ json: JSON) throws {
        if json.rowid == 0{
            try self.insert(name, json)
        }else{
            try self.update(name, json.rowid, json)
        }
    }

    public func query(name:String,condition:Condition? = nil,value:[String:String] = [:]) throws ->[JSON]{
        var result:[JSON] = []
        let sql = "select *,ROWID from \(name)" + (condition != nil ? " where " + condition!.conditionCode : "")
        let rs = try self.query(sql: sql)
        for i in value {
            rs.bind(name: i.value)?.bind(value: i.value)
        }
        while try rs.step() {
            var js:Dictionary<String,JSON> = Dictionary()
            for i in 0 ..< rs.columnCount{
                let name = rs.columnName(index: i)
                let value = rs.column(index: Int32(i), type: String.self).value()
                if let data = value.data(using: .utf8){
                    do {
                        let jm = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                        if jm is Array<Any>{
                            js[name] = JSON(jm as! Array<Any>)
                        }else if jm is Dictionary<String,Any>{
                            js[name] = JSON(jm as! Dictionary<String,Any>)
                        }else{
                            js[name] = JSON(content: value)
                        }
                    } catch {
                        js[name] = JSON(content: value)
                    }
                    
                }else{
                    js[name] = JSON(content: value)
                }
            }
            result.append(JSON(content: js))
        }
        rs.close()
        return result
    }
    public func delete(name:String,rowid:Int) throws {
        let sql = "delete from \(name) where `rowid`=\(rowid)"
        try self.exec(sql: sql)
    }
    
    public func create(name:String,json:JSON) throws{
        if let dic = json.json as? Dictionary<String,Any>{
            try self.create(name, dic)
        }
        if let dic = (json.json as? Array<Dictionary<String,Any>>)?.first{
            try self.create(name, dic)
        }
        throw NSError(domain: "json is no object", code: 0, userInfo: nil)
    }
    public func create(_ name: String, _ dic: [String : Any]) throws {
        if try self.tableExists(name: name) == false{
            let col = dic.keys.map({$0 + " TEXT"}).joined(separator: ",")
            let sql = "CREATE TABLE IF NOT EXISTS  `\(name)` (\(col))"
            try self.exec(sql: sql)
        }else{
            let infos = try self.tableInfo(name: name)
            for i in dic.keys {
                if !infos.keys.contains(i){
                    try self.addColumn(name: name, columeName: i, typedef: "TEXT")
                }
            }
        }
    }
}
