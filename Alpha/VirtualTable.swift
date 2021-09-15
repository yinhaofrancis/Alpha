//
//  VirtualTable.swift
//  Alpha
//
//  Created by hao yin on 2021/9/15.
//

import Foundation
import SQLite3

//* iVersion    */ 0,
// /* xCreate     */ 0,
// /* xConnect    */ templatevtabConnect,
// /* xBestIndex  */ templatevtabBestIndex,
// /* xDisconnect */ templatevtabDisconnect,
// /* xDestroy    */ 0,
// /* xOpen       */ templatevtabOpen,
// /* xClose      */ templatevtabClose,
// /* xFilter     */ templatevtabFilter,
// /* xNext       */ templatevtabNext,
// /* xEof        */ templatevtabEof,
// /* xColumn     */ templatevtabColumn,
// /* xRowid      */ templatevtabRowid,
// /* xUpdate     */ 0,
// /* xBegin      */ 0,
// /* xSync       */ 0,
// /* xCommit     */ 0,
// /* xRollback   */ 0,
// /* xFindMethod */ 0,
// /* xRename     */ 0,
// /* xSavepoint  */ 0,
// /* xRelease    */ 0,
// /* xRollbackTo */ 0,
// /* xShadowName */ 0

public protocol VirtualTableInterface{
    var isXCreate:Bool { get }
    var isXDestroy:Bool { get }
    var isXUpdate:Bool { get }
    var isXBegin:Bool { get }
    var isXSync:Bool { get }
    var isXCommit:Bool { get }
    var isXRollback:Bool { get }
    var isXFindMethod:Bool { get }
    var isXRename:Bool { get }
    var isXSavepoint:Bool { get }
    var isXRelease:Bool { get }
    var isXRollbackTo:Bool { get }
    var isXShadowName:Bool { get }
}

public class VModule:VirtualTableInterface{
    
    public var isXCreate: Bool = false
    
    public var isXDestroy: Bool = false
    
    public var isXUpdate: Bool = false
    
    public var isXBegin: Bool = false
    
    public var isXSync: Bool = false
    
    public var isXCommit: Bool = false
    
    public var isXRollback: Bool = false
    
    public var isXFindMethod: Bool = false
    
    public var isXRename: Bool = false
    
    public var isXSavepoint: Bool = false
    
    public var isXRelease: Bool = false
    
    public var isXRollbackTo: Bool = false
     
    public var isXShadowName: Bool = false
    
    public var module:sqlite3_module = sqlite3_module()
    
    public var name:String
    
    public weak var db:Database?
    
    public init(name:String){
        self.name = name
        
    }
    public struct VTab{
        public var base:sqlite3_vtab
        public var module:VModule
    }
    public struct VTabCursor{
        public var base: sqlite3_vtab_cursor
        public var table:VTab
    }
    public func loadModule(db:Database){
        self.db = db
        self.module.xConnect = connect(db:pAux:argc:argv:ppVtab:perror:)
        self.module.xBestIndex = bestIndex(table:index:)
        self.module.xDisconnect = xdisconnect(table:)
        self.module.xOpen = xopen(table:cursor:)
        self.module.xClose = xclose(cursor:)
        self.module.xFilter = xfilter(pVtabCursor:idxNum:idxStr:argc:argv:)
        self.module.xNext = xnext(cur:)
        self.module.xEof = xeof(cur:)
        self.module.xColumn = xColumn(cur:ctx:i:)
        self.module.xRowid = xrowid(cur:prowId:)
        if self.isXCreate{
            self.module.xCreate = create(db:pAux:argc:argv:ppVtab:perror:)
        }
        sqlite3_create_module(db.sqlite, self.name, &self.module,Unmanaged.passRetained(self).toOpaque())
    }
    
    public func connect(db:Database,arg:[String],tab:inout VTab,error:inout String?){
        
    }
    public func create(db:Database,arg:[String],tab:inout VTab,error:inout String?){
        
    }
    public func open(tab:VTab)->VTabCursor?{
        return nil
    }
    public func close(cursor:VTabCursor){
        
    }
    public func filter(cursor:VTabCursor,indexNum:Int32,str:String?,valueCount:Int32,ctx:SQLContext)->Int32{
        return SQLITE_OK
    }
    public func next(cursor:VTabCursor)->Int32{
        return SQLITE_OK
    }
    
    public func bestIndex(tab:VTab,index:inout sqlite3_index_info?)->Int32{
        return SQLITE_OK
    }
    public func eof(cursor:VTabCursor)->Int32{
        return SQLITE_OK
    }
    public func row(cursor:VTabCursor)->sqlite3_int64{
        return 0
    }
    public func colume(cur:VTabCursor,ctx:SQLContext,index:Int32)->Int32{
        return SQLITE_OK
    }
}
func connect(db:OpaquePointer?,
             pAux:UnsafeMutableRawPointer?, argc:Int32, argv:UnsafePointer<UnsafePointer<CChar>?>?, ppVtab:UnsafeMutablePointer<UnsafeMutablePointer<sqlite3_vtab>?>?, perror:UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32{
    let vt = Unmanaged<VModule>.fromOpaque(pAux!).takeUnretainedValue()
    var str:[String] = []
    for i in 0 ..< argc {
        if let oArgv = argv?.advanced(by: Int(i)).pointee{
            str.append(String(cString: oArgv))
        }
    }
    var error:String?
    var vtm = VModule.VTab(base: sqlite3_vtab(), module: vt)
    vt.connect(db: vt.db!, arg: str, tab: &vtm, error: &error)
    if let er = error {
        if let c = er.cString(using: .utf8){
            let p = UnsafeMutablePointer<CChar>.allocate(capacity: c.count)
            memcpy(p, c, c.count)
            if let pe = perror{
                pe.pointee = p
            }
            
        }
    }
    
    ppVtab?.pointee = sqlite3_malloc64(sqlite3_uint64(MemoryLayout<VModule.VTab>.size)).assumingMemoryBound(to: sqlite3_vtab.self)
    memcpy(ppVtab?.pointee, &vtm, MemoryLayout<VModule.VTab>.size)
    if((error) != nil){
        return SQLITE_NOMEM
    }else{
        return SQLITE_OK
    }
}
func create(db:OpaquePointer?, pAux:UnsafeMutableRawPointer?, argc:Int32, argv:UnsafePointer<UnsafePointer<CChar>?>?, ppVtab:UnsafeMutablePointer<UnsafeMutablePointer<sqlite3_vtab>?>?, perror:UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32{
    let vt = Unmanaged<VModule>.fromOpaque(pAux!).takeUnretainedValue()
    var str:[String] = []
    for i in 0 ..< argc {
        if let oArgv = argv?.advanced(by: Int(i)).pointee{
            str.append(String(cString: oArgv))
        }
    }
    var error:String?
    var vtm = VModule.VTab(base: sqlite3_vtab(), module: vt)
    vt.create(db: vt.db!, arg: str, tab: &vtm, error: &error)
    if let er = error {
        if let c = er.cString(using: .utf8){
            let p = UnsafeMutablePointer<CChar>.allocate(capacity: c.count)
            memcpy(p, c, c.count)
            if let pe = perror{
                pe.pointee = p
            }
            
        }
    }
    
    ppVtab?.pointee = sqlite3_malloc64(sqlite3_uint64(MemoryLayout<VModule.VTab>.size)).assumingMemoryBound(to: sqlite3_vtab.self)
    memcpy(ppVtab?.pointee, &vtm, MemoryLayout<VModule.VTab>.size)
    if((error) != nil){
        return SQLITE_NOMEM
    }else{
        return SQLITE_OK
    }
}

func bestIndex(table:UnsafeMutablePointer<sqlite3_vtab>?, index:UnsafeMutablePointer<sqlite3_index_info>?) -> Int32 {
    let a = unsafeBitCast(table, to: UnsafeMutablePointer<VModule.VTab>.self)
    var info = index?.pointee
    return a.pointee.module.bestIndex(tab: a.pointee, index: &info)
}
func xdisconnect(table:UnsafeMutablePointer<sqlite3_vtab>?)->Int32{
    sqlite3_free(table)
    return SQLITE_OK
}
func xopen(table:UnsafeMutablePointer<sqlite3_vtab>?, cursor:UnsafeMutablePointer<UnsafeMutablePointer<sqlite3_vtab_cursor>?>?) -> Int32{
    let a = unsafeBitCast(table, to: UnsafeMutablePointer<VModule.VTab>.self)
    let pointer = sqlite3_malloc64(sqlite3_uint64(MemoryLayout<VModule.VTabCursor>.size)).assumingMemoryBound(to: VModule.VTabCursor.self)
    pointer.pointee = VModule.VTabCursor(base: sqlite3_vtab_cursor(), table: a.pointee)
    cursor?.pointee = unsafeBitCast(cursor, to: UnsafeMutablePointer<sqlite3_vtab_cursor>.self)
    return (a.pointee.module.open(tab: a.pointee) != nil) ? SQLITE_OK : SQLITE_ERROR
}
func xclose(cursor:UnsafeMutablePointer<sqlite3_vtab_cursor>?) -> Int32{
    let cur = unsafeBitCast(cursor, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    cur.pointee.table.module.close(cursor: cur.pointee)
    sqlite3_free(cursor)
    return SQLITE_OK
}
func xfilter(pVtabCursor:UnsafeMutablePointer<sqlite3_vtab_cursor>?, idxNum:Int32, idxStr:UnsafePointer<CChar>?, argc:Int32, argv:UnsafeMutablePointer<OpaquePointer?>?) -> Int32{
    let cur = unsafeBitCast(pVtabCursor, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    let s = idxStr == nil ? nil : String(cString: idxStr!)
    let c = SQLContext()
    c.values = argv
    return cur.pointee.table.module.filter(cursor: cur.pointee, indexNum: idxNum, str: s, valueCount: argc, ctx: c)
}
func xnext(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    return cursor.pointee.table.module.next(cursor: cursor.pointee)
}
func xeof(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    return cursor.pointee.table.module.eof(cursor: cursor.pointee)
}
func xrowid(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?, prowId:UnsafeMutablePointer<sqlite3_int64>?) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    let rowid = cursor.pointee.table.module.row(cursor: cursor.pointee)
    prowId?.pointee = rowid
    return SQLITE_OK
}
func xColumn(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?, ctx:OpaquePointer?, i:Int32) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    let context = SQLContext()
    context.ctx = ctx
    return cursor.pointee.table.module.colume(cur: cursor.pointee, ctx: context, index: i)
}
