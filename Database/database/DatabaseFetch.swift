//
//  DatabaseFetch.swift
//  Ammo
//
//  Created by hao yin on 2022/4/22.
//

import Foundation

public class FetchColume{
    public var colume:String
    public var value:DBType?
    public var align:Bool = false
    public init(colume:String,type:DatabaseProtocol.Type? = nil){
        self.align = type != nil
        self.colume = colume
    }
}

@propertyWrapper
/// 查询列属性包裹器
public class QueryColume<T:DBType>:FetchColume{

    public var wrappedValue:T{
        get{
            return self.value as! T
        }
        set{
            self.value = newValue
        }
    }
    public init(wrappedValue:T,colume:String){
        super.init(colume: colume, type: nil)
        self.value = wrappedValue
    }
    /// Query Colume
    /// - Parameters:
    ///   - wrappedValue: wrappedValue
    ///   - function: SQL 函数
    ///   - colume: 列名
    ///   - type: 实体类型  链接查询时必选
    public init(wrappedValue:T,function:String,colume:String,type:DatabaseProtocol.Type? = nil){
        if let t = type{
            let c = "\(function)(\(t.name).\(colume))"
            super.init(colume:c, type: type)
            self.value = wrappedValue
        }else{
            let c = "\(function)(\(colume))"
            super.init(colume:c, type: type)
            self.value = wrappedValue
        }
        self.align = true;
    }
    /// Query Colume
    /// - Parameters:
    ///   - wrappedValue: wrappedValue
    ///   - colume: 列名
    ///   - type: 实体类型  链接查询时必选
    public init(wrappedValue:T,colume:String,type:DatabaseProtocol.Type? = nil){
        if let t = type{
            super.init(colume: t.name + "." + colume, type: type)
            self.value = wrappedValue
        }else{
            super.init(colume: colume, type: type)
            self.value = wrappedValue
        }
    }
    
    /// JSON Query Colume
    /// - Parameters:
    ///   - wrappedValue: wrappedValue
    ///   - colume: 列名
    ///   - jsonKeyPath: json key path
    ///   - type: 实体类型 链接查询时必选
    ///   json key path
    ///   json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$') → '{"a":2,"c":[4,5,{"f":7}]}'
    ///   json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.c') → '[4,5,{"f":7}]'
    ///   json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.c[2]') → '{"f":7}'
    ///   json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.c[2].f') → 7
    ///   json_extract('{"a":2,"c":[4,5],"f":7}','$.c','$.a') → '[[4,5],2]'
    ///   json_extract('{"a":2,"c":[4,5],"f":7}','$.c[#-1]') → 5
    ///   json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.x') → NULL
    ///   json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.x', '$.a') → '[null,2]'
    ///   json_extract('{"a":"xyz"}', '$.a') → 'xyz'
    ///   json_extract('{"a":null}', '$.a') → NULL
    ///
    public init(wrappedValue:T,colume:String,jsonKeyPath:String,type:DatabaseProtocol.Type? = nil){
        let c = "json_extract(\((type == nil ? "" : type!.name + ".")  + colume),\(jsonKeyPath))"
        super.init(colume: c, type: type)
        self.value = wrappedValue
    }
}


/// 数据查询对象
open class DatabaseFetchObject{
    /// 链接类型
    public enum Join{
        case leftJoin
        case crossJoin
        case join
        case innerJoin
        var code:String{
            switch(self){
            case .leftJoin:
                return " LEFT JOIN "
            case .crossJoin:
                return " CROSS JOIN "
            case .join:
                return " JOIN "
            case .innerJoin:
                return " INNER JOIN "
            }
        }
    }
    /// 创建查询
    /// - Parameter table: 实体类型
    /// - Returns: 查询对象
    public static func fetch(table:DatabaseProtocol.Type)->Fetch{
        let sample = Self()
        let f = Fetch()
        f.select(sample: sample, table: table)
        return f
    }
    
    /// 查询对象的定义
    public var declare:[String:FetchColume]{
        return Mirror(reflecting: self).children.filter { kv in
            (kv.value as? FetchColume) != nil
        }.reduce(into: [:]) { partialResult, kv in
            let fc = kv.value as! FetchColume
            partialResult[fc.align ? kv.label! : fc.colume] = fc
        }
    }
    public required init() {}
    
    
    public class Fetch{
        var sql:String = ""
        var join:[String] = []
        var condition:String = ""
        var having:String = ""
        var sort:[String] = []
        var groupby:String = ""
        fileprivate func select<T:DatabaseFetchObject>(sample:T,table:DatabaseProtocol.Type){
            self.sql = "select \(sample.declare.map({$0.value.colume + "\($0.value.align ? " as \($0.key)" : "")"}).joined(separator: ",")) from \(table.name)"
        }
        /// 链接查询
        /// - Parameters:
        ///   - join: 链接模式
        ///   - table: 链接的实体名
        ///   - condition: 条件描述
        /// - Returns: 查询对象
        public func joinQuery(join:Join,table:DatabaseProtocol.Type,condition:QueryCondition? = nil)->Fetch{
            self.join.append(" \(join.code) \(table.name) \(condition == nil ? "" : "ON \(condition!.condition)")")
            return self
        }
        /// where 条件
        /// - Parameter condition: 条件描述
        /// - Returns: 查询对象
        public func whereCondition(condition:QueryCondition)->Fetch{
            self.condition = " where \(condition.condition)"
            return self
        }
        /// 排序
        /// - Parameters:
        ///   - key: 排序Key
        ///   - desc: 是否倒叙
        /// - Returns: 查询对象
        public func orderBy(key:QueryCondition.Key,desc:Bool)->Fetch{
            self.sort.append("\(key.key) \(desc ? "DESC" : "ASC")")
            return self
        }
        /// 分组
        /// - Parameter key: group by <key>
        /// - Returns: 查询对象
        public func groupBy(key:QueryCondition.Key...)->Fetch{
            self.groupby = " group by \(key.map({$0.key}).joined(separator: ","))"
            return self
        }
        /// having
        /// - Parameter condition: 条件
        /// - Returns: 查询对象
        public func having(condition:QueryCondition)->Fetch{
            self.having = "HAVING \(condition.condition)"
            return self
        }
        /// 执行查询
        /// - Parameters:
        ///   - db: 数据库对象
        ///   - param: 参数
        /// - Returns: 结果
        public func query<T:DatabaseFetchObject>(db:Database,param:[String:DBType]? = nil) throws->[T]{
            let sql = self.selectCode
            let rs = try db.prepare(sql: sql)
            if let v = param{
                for i in v {
                    try rs.bind(name: i.key, value: i.value)
                }
            }
            
            var array:[T] = []
            while try rs.step() == .hasColumn {
                let model = T()
                let dec = model.declare
                for i in 0 ..< rs.columeCount{
                    let id = rs.columeName(index: i)
                    if let col = dec[id]{
                        col.value = DatabaseObject.colume(rs:rs, index: i)
                    }else{
                        continue
                    }
                }
                array.append(model)
            }
            return array
        }
        public var selectCode:String{
            return self.sql
            + join.joined(separator: " ")
            + condition
            + self.groupby
            + self.having
            + (self.sort.count > 0 ? " order by \(self.sort.joined(separator: ","))" : "")
        }
    }
}


/// 视图协议
public protocol DatabaseFetchViewProtocol{
    var viewFetch:DatabaseFetchObject.Fetch { get }
    var name:String { get }
    init()
    associatedtype Objects:DatabaseFetchObject
}

extension DatabaseFetchViewProtocol{
    /// 创建视图
    /// - Parameter db: 数据库
    public func createView(db:Database) throws {
        let sql = "create view if not exists \(self.name) as " + self.viewFetch.selectCode
        let rs = try db.prepare(sql: sql)
        defer{
            rs.close()
        }
        _ = try rs.step()
        
    }
    /// 视图查询
    /// - Parameters:
    ///   - db: 数据库
    ///   - condition: 条件
    ///   - param: 参数
    /// - Returns: 结果
    public func query(db:Database,condition:QueryCondition? = nil ,param:[String:DBType]? = nil) throws ->[Objects]{
        var sql = "select * from \(self.name) "
        if let condition = condition {
            sql += " where "
            sql += condition.condition
        }
        let rs = try db.prepare(sql: sql)
        defer{
            rs.close()
        }
        if let param = param, condition != nil{
            for i in param{
                try rs.bind(name: i.key, value: i.value)
            }
        }
        var array:[Objects] = []
        
        while try rs.step() == .hasColumn{
            let o = Objects()
            for i in 0 ..< rs.columeCount{
                o.declare[rs.columeName(index: i)]?.value = rs.columeDBType(index: i)
            }
            array.append(o)
        }
        
        return array
    }
    public func drop(db:Database){
        db.exec(sql: "drop view \(self.name)")
    }
}



