//
//  DataBaseFetch.swift
//  Ammo
//
//  Created by hao yin on 2022/4/22.
//

import Foundation

public class FetchColume{
    public var colume:String
    public var value:DBType?
    public var align:Bool = false
    public init(colume:String,type:DataBaseProtocol.Type? = nil){
        self.align = type != nil
        self.colume = colume
    }
}

@propertyWrapper
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
    public init(wrappedValue:T,function:String,colume:String,type:DataBaseProtocol.Type? = nil){
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
    public init(wrappedValue:T,colume:String,type:DataBaseProtocol.Type? = nil){
        if let t = type{
            super.init(colume: t.name + "." + colume, type: type)
            self.value = wrappedValue
        }else{
            super.init(colume: colume, type: type)
            self.value = wrappedValue
        }
    }
    public init(wrappedValue:T,colume:String,jsonKeyPath:String,type:DataBaseProtocol.Type? = nil){
        let c = "json_extract(\((type == nil ? "" : type!.name + ".")  + colume),\(jsonKeyPath))"
        super.init(colume: c, type: type)
        self.value = wrappedValue
    }
}


open class DataBaseFetchObject{
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
    public static func fetch(table:DataBaseProtocol.Type)->Fetch{
        let sample = Self()
        let f = Fetch()
        f.select(sample: sample, table: table)
        return f
    }
    
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
        public func select<T:DataBaseFetchObject>(sample:T,table:DataBaseProtocol.Type){
            self.sql = "select \(sample.declare.map({$0.value.colume + "\($0.value.align ? " as \($0.key)" : "")"}).joined(separator: ",")) from \(table.name)"
        }
        public func joinQuery(join:Join,table:DataBaseProtocol.Type,condition:QueryCondition? = nil)->Fetch{
            self.join.append(" \(join.code) \(table.name) \(condition == nil ? "" : "ON \(condition!.condition)")")
            return self
        }
        public func whereCondition(condition:QueryCondition)->Fetch{
            self.condition = " where \(condition.condition)"
            return self
        }
        public func orderBy(key:QueryCondition.Key,desc:Bool)->Fetch{
            self.sort.append("\(key.key) \(desc ? "DESC" : "ASC")")
            return self
        }
        public func groupBy(key:QueryCondition.Key...)->Fetch{
            self.groupby = " group by \(key.map({$0.key}).joined(separator: ","))"
            return self
        }
        public func having(condition:QueryCondition)->Fetch{
            self.having = "HAVING \(condition.condition)"
            return self
        }
        public func query<T:DataBaseFetchObject>(db:DataBase,param:[String:DBType]? = nil) throws->[T]{
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
                        col.value = DataBaseObject.colume(rs:rs, index: i)
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


public protocol DataBaseFetchViewProtocol{
    var fetch:DataBaseFetchObject.Fetch { get }
    var name:String { get }
    associatedtype Objects:DataBaseFetchObject
}

extension DataBaseFetchViewProtocol{
    public func createView(db:DataBase) throws {
        let sql = "create view if not exists \(self.name) as " + self.fetch.selectCode
        let rs = try db.prepare(sql: sql)
        _ = try rs.step()
        rs.close()
    }
    public func query(db:DataBase,condition:QueryCondition? = nil ,param:[String:DBType]? = nil) throws ->[Objects]{
        var sql = "select * from \(self.name) "
        if let condition = condition {
            sql += " where "
            sql += condition.condition
        }
        let rs = try db.prepare(sql: sql)
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
        rs.close()
        return array
    }
    public func drop(db:DataBase){
        db.exec(sql: "drop view \(self.name)")
    }
}



