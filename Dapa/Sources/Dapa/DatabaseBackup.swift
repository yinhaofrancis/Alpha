//
//  DatabaseBackup.swift
//  
//
//  Created by wenyang on 2023/3/18.
//

import Foundation
import SQLite3

public class DatabaseBackup{
    
    public var backupDb:Database
    
    public var database:Database
    
    public init(url:URL,database:Database) throws{
        self.backupDb = try Database(url: url)
        self.database = database
    }
    
    public init(name:String,database:Database) throws{
        self.backupDb = try Database(name: name)
        self.database = database
    }
    
    public func backup(){
        let back = sqlite3_backup_init(self.backupDb.sqlite!, "main", self.database.sqlite!, "main");
        if(back != nil){
            repeat{
                let rc = sqlite3_backup_step(back, 5)
                let count = sqlite3_backup_pagecount(back)
                let remain = sqlite3_backup_remaining(back)
                if(remain >= count){
                    break
                }
            }while(true);
        }
        self.backupDb.close()
        self.database.close()
    }
}


