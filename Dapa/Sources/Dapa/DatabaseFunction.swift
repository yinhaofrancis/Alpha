//
//  File.swift
//  
//
//  Created by wenyang on 2023/3/18.
//

import Foundation
import SQLite3

public protocol DatabaseFuntion{
    var name:String { get }
    var nArg:Int32 { get }
//    func xFunc(sqlite3_context*,int,sqlite3_value**)
//    func xStep(sqlite3_context*,int,sqlite3_value**)
//    func xFinal(sqlite3_context)
}
