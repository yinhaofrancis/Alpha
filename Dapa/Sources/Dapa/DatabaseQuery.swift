//
//  File.swift
//  
//
//  Created by wenyang on 2023/3/15.
//

import Foundation

public struct DatabaseQuery{
    public var sql:DatabaseExpress
    public init(sql:DatabaseExpress){
        self.sql = sql
    }
    public func query<T:DatabaseResult>(db:Database,param:[String:Any] = [:]) throws ->[T] {
        let rs = try db.prepare(sql: self.sql.sqlCode)
        var results:[T] = []
        for i in param{
            try rs.bind(name: i.key, value: i.value)
        }
        while try rs.step() == .hasColumn {
            var result = T()
            rs.colume(model: &result)
            results.append(result)
        }
        rs.close()
        return results
    }
    public func exec(db:Database,param:[String:Any] = [:]) throws {
        let rs = try db.prepare(sql: self.sql.sqlCode)
        for i in param{
            try rs.bind(name: i.key, value: i.value)
        }
        try rs.step()
        rs.close()
    }
}

public protocol DatabaseQueryModel:DatabaseResult{
    static var queryDeclare:[DatabaseQueryColumeDeclare] { get }
    static var table:DatabaseGenerator.Select.JoinTable { get }
}

extension DatabaseQueryModel{
    public func query(condition:DatabaseGenerator.DatabaseCondition? = nil,
                      orderBy: [DatabaseGenerator.OrderBy] = [],
                      limit:UInt64? = nil,
                      offset:UInt64? = nil)->DatabaseQuery{
        let array:[DatabaseGenerator.ResultColume] = Self.queryDeclare.map { dqcd in
                .colume(name: dqcd.name)
        }
        let sql = DatabaseGenerator.Select(colume: array, tableName: Self.table, condition: condition, groupBy: [], orderBy: orderBy, limit: limit, offset: offset)
        return DatabaseQuery(sql: sql)
    }
}
