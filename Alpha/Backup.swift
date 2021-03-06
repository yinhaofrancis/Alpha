//
//  Backup.swift
//  Alpha
//
//  Created by wenyang on 2021/7/25.
//

import Foundation
import SQLite3

public class BackupDatabase{
    var backUpDb:OpaquePointer?
    var sourceDB:DB
    var pbackUp:OpaquePointer?
    var backupToEnd = false
    var remaining:Int{
        guard let bk = self.pbackUp else { return 0 }
        return Int(sqlite3_backup_remaining(bk))
    }
    /// 数据页数
    var pageCount:Int {
        guard let bk = self.pbackUp else { return 0 }
        return Int(sqlite3_backup_pagecount(bk))
    }
    /// 数据库备份
    /// - Parameters:
    ///   - url: 备份列表
    ///   - source: 数据库来源
    public init(url:URL,source:DB) throws{
        let r2 = sqlite3_open_v2(url.path, &self.backUpDb, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        self.sourceDB = source
        if r2 != SQLITE_OK {
            print(DB.errormsg(pointer: backUpDb))
            try FileManager.default.removeItem(at: url)
            let r2 = sqlite3_open_v2(url.path, &self.backUpDb, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
            self.sourceDB = source
            if r2 != SQLITE_OK{
                throw NSError(domain: "create Back error", code: 0, userInfo: nil)
            }
        }
    }
    
    /// 备份
    /// - Parameter page: 备份的页数 默认 备份所有
    public func backup(page:Int = -1) throws {
        if self.pbackUp == nil{
            let p = sqlite3_backup_init(backUpDb, "main",sourceDB.sqlite , "main")
            self.pbackUp = p
        }
        
        if(self.pbackUp == nil){
            let error = DB.errormsg(pointer: self.pbackUp)
            throw NSError(domain:error , code: 0, userInfo: nil)
        }
        repeat{
            print(self.remaining,self.pageCount)
            let r = sqlite3_backup_step(self.pbackUp, Int32(page))
            if r == SQLITE_OK || r == SQLITE_BUSY || r == SQLITE_LOCKED{
                sqlite3_sleep(100)
            }else{
                if r == SQLITE_DONE{
                    break
                }
                let error = DB.errormsg(pointer: self.pbackUp)
                throw NSError(domain:error , code: 0, userInfo: nil)
            }
        }while (self.remaining != self.pageCount)

        sqlite3_backup_finish(self.pbackUp)
    }
    deinit {
        sqlite3_close(self.backUpDb)
    }
}
