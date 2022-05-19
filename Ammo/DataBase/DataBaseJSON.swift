//
//  DataBaseJSON.swift
//  Ammo
//
//  Created by hao yin on 2022/4/24.
//

import Foundation

@dynamicMemberLookup
public struct JSONModel:ExpressibleByArrayLiteral,
                   ExpressibleByDictionaryLiteral,
                        ExpressibleByStringLiteral,DBType,CustomStringConvertible{
    public func bind(rs: DataBase.ResultSet, index: Int32) throws {
        try rs.bind(index: index, value: self)
    }
    
    public static func create(rs: DataBase.ResultSet, index: Int32) -> JSONModel? {
        rs.columeJSON(index: index)
    }
    
    public var stringValue: String{
        return "\"\(self.jsonString)\""
    }
    
    public var asDefault: String?{
        return ""
    }
    
    public static var originType: CollumnDecType = .jsonDecType
    
    public var isNull: Bool{
        return false
    }
    
    public typealias ArrayLiteralElement = [Any]
    
    public typealias Key = String
    
    public typealias Value = Any
    
    public typealias StringLiteralType = String
    
    public var content:Any
    
    public var array:[JSONModel]{
        get{
            guard let c = self.content as? [Any] else { return [] }
            return c.map({JSONModel(content: $0)})
        }
        set{
            self.content = newValue.map({$0.content})
        }
        
    }
    public var object:[String:JSONModel]{
        get{
            let a:[String:JSONModel] = (self.content as? [String:Any])?.reduce(into: [:], { partialResult, kv in
                partialResult[kv.key] = JSONModel(content: kv.value)
            }) ?? [:]
            return a
        }
        set{
            self.content = newValue.reduce(into: [:], { partialResult, kv in
                partialResult[kv.key] = kv.value.content
            })
        }
        
    }
    public var string:String?{
        get{
            self.content as? String ?? ""
        }
        set{
            self.content = newValue as Any
        }
    }
    public var integer:Int?{
        get{
            self.content as? Int
        }
        set{
            self.content = newValue as Any
        }
    }
    public var float:Float?{
        get{
            self.content as? Float
        }
        set{
            self.content = newValue as Any
        }
    }
    public var bool:Bool{
        get{
            if self.string?.lowercased() == "true"{
                return true
            }else if self.integer ?? 0 > 0{
                return true
            }else{
                return false
            }
        }
        set{
            self.content = newValue ? 1 : 0
        }
    }
    public subscript(dynamicMember dynamicMember:String)->JSONModel?{
        get{
            self.object[dynamicMember]
        }
        set{
            self.object[dynamicMember] = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->String?{
        get{
            self.object[dynamicMember]?.string
        }
        set{
            self.object[dynamicMember]?.string = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Int?{
        get{
            self.object[dynamicMember]?.integer
        }
        set{
            self.object[dynamicMember]?.integer = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Bool{
        get{
            self.object[dynamicMember]?.bool ?? false
        }
        set{
            self.object[dynamicMember]?.bool = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Float?{
        get{
            self.object[dynamicMember]?.float
        }
        set{
            self.object[dynamicMember]?.float = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Any{
        get{
            self.object[dynamicMember]?.content as Any
        }
        set{
            self.object[dynamicMember]?.content = newValue
        }
    }
    public subscript(index:Int)->JSONModel{
        get{
            return self.array[index]
        }
        set{
            self.array[index] = newValue
        }
    }
    public subscript(index:Int)->Any{
        get{
            return self.array[index].content
        }
        set{
            self.array[index].content = newValue
        }
    }
    public subscript(index:Int)->String{
        get{
            return self.array[index].string ?? ""
        }
        set{
            self.array[index].string = newValue
        }
    }
    public subscript(index:Int)->Float{
        get{
            return self.array[index].float ?? 0.0
        }
        set{
            self.array[index].float = newValue
        }
    }
    public subscript(index:Int)->Int{
        get{
            return self.array[index].integer ?? 0
        }
        set{
            self.array[index].integer = newValue
        }
    }
    public init(stringLiteral content:String){
        self.content = content
    }
    public init(content:Any){
        self.content = content
    }
    public init(arrayLiteral elements: [Any]...) {
        self.content = elements
    }
    public init(dictionaryLiteral elements: (String, Any)...) {
        let a:[String:Any] = elements.reduce(into: [:], { partialResult, kv in
            partialResult[kv.0] = kv.1
        })
        self.content = a
    }
    public init(unicodeScalarLiteral value: String) {
        self.content = value
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.content = value
    }
    public init(object:[String:Any]){
        let v:[String:JSONModel] = object.reduce(into: [:]) { partialResult, kv in
            partialResult[kv.key] = JSONModel(content: kv.value)
        }
        self.content = v
    }
    public init(array:[Any]){
        self.content = array.map({JSONModel(content: $0)})
    }
    public init(jsonData:Data){
        self.content = (try? JSONSerialization.jsonObject(with: jsonData)) ?? ""
    }
    public var jsonString:String{
        guard let da = try? JSONSerialization.data(withJSONObject: self.content, options: .fragmentsAllowed) else { return "" }
        return String(data: da, encoding: .utf8) ?? ""
    }
    public var description: String{
        return self.jsonString
    }
}

public struct JSONObject:DataBaseProtocol,CustomStringConvertible{
    public init() {
        
    }
    
    public var description: String{
        return self.json?.description ?? ""
    }
    
    public static var name: String = "JSON"
    @Col(name: "json")
    public var json:JSONModel? = nil
    
    @Col(name: "row", primaryKey: true,autoInc:true)
    fileprivate var rowid:Int? = nil
    
    public init(db:DataBase) { }
    
    public init(json:JSONModel){
        self.json = json
    }
    public static func save(db:DataBase,json:JSONObject) throws{
        try json.save(db: db)
    }
    public func save(db:DataBase) throws{
        try self.tableModel.insert(db: db)
    }
}
