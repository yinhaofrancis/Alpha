//
//  DatabaseModel.swift
//  Alpha
//
//  Created by hao yin on 2022/4/19.
//

import Foundation

open class DataBaseObject:NSObject{
    public var name:String{
        return NSStringFromClass(self.classForCoder).replacingOccurrences(of: ".", with: "_")
    }
    public var declare:TableDeclare{
        let cds = Mirror(reflecting: self).children.filter({$0.value is CollumnDeclare}).map { m in
            m.value as! CollumnDeclare
        }
        return TableDeclare(name: self.name, declare: cds)
    }
    public var tableModel:TableModel{
        TableModel(name: self.name, declare: Mirror(reflecting: self).children.filter({$0.value is TableColumn}).map ({$0.value as! TableColumn}))
    }
}

public protocol DBType{
    static var originType:CollumnDecType { get }
    var isNull:Bool { get }
}

extension Int:DBType{
    public static var originType: CollumnDecType {
        return .intDecType
    }
    public var isNull: Bool{
        return false
    }
}
extension String:DBType{
    public static var originType: CollumnDecType {
        return .textDecType
    }
    public var isNull: Bool{
        return false
    }
}
extension Double:DBType{
    public static var originType: CollumnDecType {
        return .doubleDecType
    }
    public var isNull: Bool{
        return false
    }
}
extension Data:DBType{
    public static var originType: CollumnDecType {
        return .dataDecType
    }
    public var isNull: Bool{
        return false
    }
}

extension Optional:DBType where Wrapped:DBType{
    public static var originType: CollumnDecType {
        Wrapped.originType
    }
    public var isNull: Bool{
        return self == nil
    }
}

@propertyWrapper
public class Col<T:DBType>:TableColumn{
    
    public var wrappedValue:T{
        get{
            self.origin as! T
        }
        set{
            self.origin = newValue
        }
    }
    public init(wrappedValue:T,name:String){
        super.init(value:wrappedValue, type:T.originType, nullable: true, name: name, primaryKey: false, unique: false)
    }
    public init(wrappedValue:T,name:String,primaryKey: Bool){
        super.init(value:wrappedValue,type:T.originType, nullable: true, name: name, primaryKey: primaryKey, unique: false)
    }
}


