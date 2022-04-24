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
                        ExpressibleByStringLiteral,DBType{
    public static var originType: CollumnDecType = .jsonDecType
    
    public var isNull: Bool{
        return false
    }
    
    public typealias ArrayLiteralElement = [JSONModel]
    
    public typealias Key = String
    
    public typealias Value = JSONModel
    
    public typealias StringLiteralType = String
    
    public var content:Any
    
    public var array:[JSONModel]{
        get{
            return self.content as? [JSONModel] ?? []
        }
        set{
            self.content = newValue
        }
        
    }
    public var object:[String:JSONModel]{
        get{
            return self.content as? [String:JSONModel] ?? [:]
        }
        set{
            self.content = newValue
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
    public init(arrayLiteral elements: [JSONModel]...) {
        self.content = elements
    }
    public init(dictionaryLiteral elements: (String, JSONModel)...) {
        let a:[String:JSONModel] = elements.reduce(into: [:], { partialResult, kv in
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
}
