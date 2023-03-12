//
//  File.swift
//  
//
//  Created by wenyang on 2023/3/8.
//

import Foundation


public protocol DatabaseExpress{
    var sqlCode:String { get }
}
public class DatabaseGenerator {}
extension DatabaseGenerator{
    
    public enum ResultColume:CustomStringConvertible{
        case colume(name:String)
        case alias(name:String,alias:String)
        public var description: String{
            switch self{
                
            case .colume(name: let name):
                return name
            case .alias(name: let name, alias: let alias):
                return name + " AS " + alias
            }
        }
    }
    public struct OrderBy:CustomStringConvertible{
        public init(colume: String, asc: Bool) {
            self.colume = colume
            self.asc = asc
        }
        public var description: String{
            colume + " " + (asc ? "ASC" : "DESC")
        }
        public var colume:String
        public var asc:Bool
        
    }

    public struct Select:DatabaseExpress{
        public init(colume: [ResultColume] = [],
                   tableName: DatabaseGenerator.Select.JoinTable,
                   condition: String? = nil,
                   groupBy: [String] = [],
                   orderBy: [OrderBy] = [],
                   limit: UInt64? = nil,
                   offset: UInt64? = nil) {
            self.colume = colume
            self.tableName = tableName
            self.condition = condition
            self.groupBy = groupBy
            self.orderBy = orderBy
            self.limit = limit
            self.offset = offset
        }
        
        public var sqlCode: String{
            let c = colume.count > 0 ? colume.map{$0.description}.joined(separator: ",") : " * "
            let condition = self.condition != nil ? " WHERE " + self.condition! : ""
            let group = self.groupBy.count == 0 ? "" : " GROUP BY \(groupBy.joined(separator: ","))"
            let offset = offset == nil ? "" : " OFFSET " + offset!.description
            let limit = limit == nil ? "" : " LIMIT " + limit!.description
            let order = orderBy.count == 0 ? "" : " ORDER BY " + orderBy.map {$0.description}.joined(separator: ",")
            return "SELECT " + c + " from " + tableName.table + condition + group + order + limit + offset
        }
        
        public var colume:[ResultColume] = []
        public var tableName:JoinTable
        public var condition:String? = nil
        public var groupBy:[String] = []
        public var orderBy:[OrderBy] = []
        public var limit:UInt64? = nil
        public var offset:UInt64? = nil
        
        public enum TableJoin:String{
            case leftJoin = " LEFT JOIN "
            case crossJoin = " CROSS JOIN "
            case join = " JOIN "
            case innerJoin = " INNER JOIN "
        }
        public struct JoinTable{
            public var table:String
            public init(table:TableName){
                self.table = table.description
            }
            public func join(type:TableJoin,table:TableName)->JoinTable{
                var jt = JoinTable(table: .name(name: ""))
                jt.table = self.table + " " + type.rawValue + table.description
                return jt
            }
        }
    }
}

extension DatabaseGenerator {
    public enum TableName:CustomStringConvertible{
        case withSchema(schema:String,name:String)
        case name(name:String)
        public var description: String{
            switch self{
            case .withSchema(schema: let schema, name: let name):
                return schema + "." + name
            case .name(name: let name):
                return name
            }
        }
    }

    public struct Table:DatabaseExpress{
        public init(istemp: Bool = false,
                    ifNotExists: Bool = false,
                    tableName: TableName,
                    columeDefine: [DatabaseColumeDeclare]) {
            self.istemp = istemp
            self.ifNotExists = ifNotExists
            self.tableName = tableName
            self.columeDefine = columeDefine
        }

        public var istemp:Bool = false
        
        public var ifNotExists:Bool = false
        
        public var tableName:TableName
        
        public var columeDefine:[DatabaseColumeDeclare]
        
        public var sqlCode:String{
            let code = "CREATE \( istemp ? "TEMP" : "") TABLE \(ifNotExists ? "IF NOT EXISTS" : "") \(tableName)"
            let cd = columeDefine
            let dec = cd.map{$0.name + " " + $0.type.rawValue + "\($0.notNull ? " NOT NULL" : "")"} .joined(separator: ",")
            let pd = cd.filter{$0.primary}.map{$0.name}.joined(separator: ",")
             
            let primary =  pd.count > 0 ? ",PRIMARY KEY (\(pd))" : ""
            
            let ud = cd.filter{$0.unique}.map{$0.name}.joined(separator: ",")
            let uniq = ud.count > 0 ? ",UNIQUE (\(ud))" : ""
            let def = "(\(dec)\(primary)\(uniq))"
            return code + def
        }
    }
}

extension DatabaseGenerator {
    public struct Insert:DatabaseExpress{
        public enum InsertType:String{
            case insert = "INSERT INTO"
            case replace = "REPLACE INTO"
            case insertReplace = "INSERT OR REPLACE INTO"
        }
        public var sqlCode: String{
            "\(insertType.rawValue) \(table) \(colume.count == 0 ? "" : "(" + colume.joined(separator: ",") + ")")" +  value
        }
        
        public var table:String
        public var colume:[String]
        public var value:String
        public var insertType:InsertType
        
        public init(insert:InsertType, table: TableName, colume: [String], value: [String]) {
            self.table = table.description
            self.colume = colume
            self.insertType = insert
            self.value = " VALUES (\(value.joined(separator: ",")))"
        }
        public init(insert:InsertType,table: TableName, colume: [String], value: Select) {
            self.insertType = insert
            self.table = table.description
            self.colume = colume
            self.value = value.sqlCode
        }
    }
}

extension DatabaseGenerator {
    public struct Delete:DatabaseExpress{
        public var sqlCode: String{
            
            "DELETE FROM " + self.table.description + " WHERE " + condition
        }
        
        public var table:TableName
        public var condition:String
        
        public init(table: TableName, condition:String) {
            self.table = table
            self.condition = condition
        }
    }
}
extension DatabaseGenerator {
    public struct Update:DatabaseExpress{
        public var sqlCode: String{
            "UPDATE " + table.description + " SET " + keyValue.map{$0.key + "=" + $0.value}.joined(separator: ",") + " WHERE " + condition
        }
        
        public var keyValue:[String:String]
        public var table:TableName
        public var condition:String
    }
}

extension DatabaseGenerator {
    public struct Index:DatabaseExpress{
        public init(isUnique: Bool = false,
                    ifNotExists: Bool = false,
                    indexName: TableName,
                    tableName:String,
                    columes: [String],
                    condition:String? = nil) {
            self.isUnique = isUnique
            self.ifNotExists = ifNotExists
            self.indexName = indexName
            self.tableName = tableName
            self.columes = columes
            self.condition = condition
        }

        public var isUnique:Bool = false
        
        public var ifNotExists:Bool = false
        
        public var tableName:String
        
        public var indexName:TableName
        
        public var columes:[String]
        
        public var condition:String?
        
        public var sqlCode:String{
            let code = "CREATE \( isUnique ? "UNIQUE" : "") INDEX \(ifNotExists ? "IF NOT EXISTS" : "") \(indexName) ON \(tableName) (\(columes.joined(separator: ",")))" + (condition == nil ? "" : " WHERE " + condition!)

            return code
        }
    }
}

