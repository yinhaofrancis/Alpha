//
//  File.swift
//  
//
//  Created by wenyang on 2023/3/8.
//

import Foundation
import SQLite3
import SQLite3.Ext

public enum CollumnType{
    case nullCollumn
    case intCollumn
    case doubleCollumn
    case textCollumn
    case dataCollumn
}

/// 列定义类型
public enum CollumnDecType:String{
    case intDecType = "INTEGER"
    case doubleDecType = "REAL"
    case textDecType = "TEXT"
    case dataDecType = "BLOB"
    case jsonDecType = "JSON"
    case dateDecType = "DATE"
    public var collumnType:CollumnType{
        switch(self){
        case .intDecType:
            return .intCollumn
        case .doubleDecType:
            return .doubleCollumn
        case .textDecType:
            return .textCollumn
        case .dataDecType:
            return .dataCollumn
        case .jsonDecType:
            return .textCollumn
        case .dateDecType:
            return .doubleCollumn
        }
    }
}

@resultBuilder
public struct ColumeDefine{
    public static func buildBlock(_ components: DatabaseColumeDeclare...) -> [DatabaseColumeDeclare] {
        return components
    }
}

public class DatabaseColumeDeclare{
    public init(name:String,
                type: CollumnDecType,
                primary: Bool = false,
                unique: Bool = false,
                notNull: Bool = false) {
        self.type = type
        self.name = name
        self.unique = unique
        self.notNull = notNull
        self.primary = primary
    }
    
    public var name:String
    public var type:CollumnDecType
    public var unique:Bool = false
    public var notNull:Bool = false
    public var primary:Bool = false

}

public protocol DatabaseModel{
    static var tableName:String { get }
    @ColumeDefine static var declare:[DatabaseColumeDeclare] { get }
}
