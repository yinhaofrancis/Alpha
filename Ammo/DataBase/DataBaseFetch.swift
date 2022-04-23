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
    public var align:String?
    public init(colume:String,type:DataBaseObject.Type? = nil){
        self.colume = (type == nil ? "" : (type!.name + ".")) + colume
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
    public init(wrappedValue:T,colume:String,type:DataBaseObject.Type,align:String){
        super.init(colume: colume, type: type)
        self.align = align
    }
}


open class DataBaseFetchObject{
    public enum Join{
        case leftJoin
        case rightJoin
        case crossJoin
        case join
        case innerJoin
        var code:String{
            switch(self){
            case .leftJoin:
                return " LEFT JOIN "
            case .rightJoin:
                return " RIGHT JOIN "
            case .crossJoin:
                return " CROSS JOIN "
            case .join:
                return " JOIN "
            case .innerJoin:
                return " INNER JOIN "
            }
        }
    }
    public static func fetch(table:DataBaseObject.Type)->Fetch{
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
            partialResult[fc.align ?? fc.colume] = fc
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
        public func select<T:DataBaseFetchObject>(sample:T,table:DataBaseObject.Type){
            self.sql = "select \(sample.declare.map({$0.value.colume + "\($0.value.align != nil ? " as \($0.value.align!)" : "")"}).joined(separator: ",")) from \(table.name)"
        }
        public func joinQuery(join:Join,table:DataBaseObject.Type,condition:QueryCondition? = nil)->Fetch{
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
        public func query<T:DataBaseFetchObject>(db:DataBase) throws->[T]{
            let sql = self.sql
            + join.joined(separator: " ")
            + condition
            + self.groupby
            + self.having
            + (self.sort.count > 0 ? " order by \(self.sort.joined(separator: ","))" : "")
            
            let rs = try db.prepare(sql: sql)
            var array:[T] = []
            while try rs.step() == .hasColumn {
                let model = T()
                let dec = model.declare
                for i in 0 ..< rs.columeCount{
                    let id = rs.columeName(index: i)
                    if let col = dec[id]{
                        col.value = rs.colume(index: i)
                    }else{
                        continue
                    }
                }
                array.append(model)
            }
            return array
        }
    }
}
