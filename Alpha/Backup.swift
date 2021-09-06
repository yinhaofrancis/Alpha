//
//  Backup.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/25.
//

import Foundation
import SQLite3

public class BackupDatabase{
    var backUpDb:OpaquePointer?
    var sourceDB:Database
    var pbackUp:OpaquePointer?
    var backupToEnd = false
    var remaining:Int{
        guard let bk = self.pbackUp else { return 0 }
        return Int(sqlite3_backup_remaining(bk))
    }
    var pageCount:Int {
        guard let bk = self.pbackUp else { return 0 }
        return Int(sqlite3_backup_pagecount(bk))
    }
    public init(url:URL,source:Database) throws{
        let r2 = sqlite3_open_v2(url.path, &self.backUpDb, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        self.sourceDB = source
        if r2 != SQLITE_OK {
            print(Database.errormsg(pointer: backUpDb))
            try FileManager.default.removeItem(at: url)
            let r2 = sqlite3_open_v2(url.path, &self.backUpDb, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
            self.sourceDB = source
            if r2 != SQLITE_OK{
                throw NSError(domain: "create Back error", code: 0, userInfo: nil)
            }
        }
    }
    
    public func backup() throws {
        if self.pbackUp == nil{
            let p = sqlite3_backup_init(backUpDb, "main",sourceDB.sqlite , "main")
            self.pbackUp = p
        }
        
        if(self.pbackUp == nil){
            let error = Database.errormsg(pointer: self.pbackUp)
            throw NSError(domain:error , code: 0, userInfo: nil)
        }
        repeat{
            print(self.remaining,self.pageCount)
            let r = sqlite3_backup_step(self.pbackUp, 1)
            if r == SQLITE_OK || r == SQLITE_BUSY || r == SQLITE_LOCKED{
                sqlite3_sleep(100)
            }else{
                if r == SQLITE_DONE{
                    break
                }
                let error = Database.errormsg(pointer: self.pbackUp)
                throw NSError(domain:error , code: 0, userInfo: nil)
            }
        }while (self.remaining != self.pageCount)

        sqlite3_backup_finish(self.pbackUp)
    }
    deinit {
        sqlite3_close(self.backUpDb)
    }
}
