//
//  VirtualTable.swift
//  Alpha
//
//  Created by hao yin on 2021/9/15.
//

import Foundation
import SQLite3.Ext

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
    
    public var module = UnsafeMutablePointer<sqlite3_module>.allocate(capacity: 1)
    
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
        public var rowid:sqlite_uint64
        public var table:VTab
        public var argc:Int = 0
        public var idNum:Int = 0
        public var idStr:String?
    }
    public func loadModule(db:Database) throws{
        self.db = db
        memset(self.module, 0, MemoryLayout<sqlite3_module>.size)
        var module = sqlite3_module()
        module.xConnect = connect(db:pAux:argc:argv:ppVtab:perror:)
        module.xBestIndex = bestIndex(table:index:)
        module.xDisconnect = xdisconnect(table:)
        module.xOpen = xopen(table:cursor:)
        module.xClose = xclose(cursor:)
        module.xFilter = xfilter(pVtabCursor:idxNum:idxStr:argc:argv:)
        module.xNext = xnext(cur:)
        module.xEof = xeof(cur:)
        module.xColumn = xColumn(cur:ctx:i:)
        module.xRowid = xrowid(cur:prowId:)
        
        if self.isXCreate{
            module.xCreate = create(db:pAux:argc:argv:ppVtab:perror:)
        }else{
            module.xCreate = connect(db:pAux:argc:argv:ppVtab:perror:)
        }
        module.iVersion = 0
        memcpy(self.module, &module, MemoryLayout<sqlite3_module>.size)
        let rs = sqlite3_create_module(db.sqlite, self.name, self.module,Unmanaged.passRetained(self).toOpaque())
        if rs != SQLITE_OK{
            throw NSError(domain:"create module", code: 0, userInfo: nil)
        }
    }
    
    public func connect(arg:[String],tab:inout VTab,error:inout String?){
        print(arg)
        sqlite3_declare_vtab(tab.module.db?.sqlite, "CREATE TABLE x(i,a HIDDEN,b HIDDEN)")
    }
    public func disconnect(tab:VTab){
        
    }
    public func create(arg:[String],tab:inout VTab,error:inout String?){
        sqlite3_declare_vtab(tab.module.db?.sqlite, "CREATE TABLE x(i,a HIDDEN,b HIDDEN)")
    }
    public func open(tab:VTab)->VTabCursor?{
        return VTabCursor(base: sqlite3_vtab_cursor(), rowid: 1, table: tab)
    }
    public func close(cursor:VTabCursor){
        
    }
    public func filter(cursor:VTabCursor,ctx:SQLContext,valueCount:Int32)->Int32{
        for i in 0 ..< valueCount{
            let s:String? = ctx.value(index: Int(i))
            print(ctx.valueType(index: Int(i)),s)
        }
  
        return SQLITE_OK
    }
    public func next(cursor:inout VTabCursor)->Int32{
        cursor.rowid += 1
        return SQLITE_OK
    }
    
    public func bestIndex(tab:VTab,index:inout sqlite3_index_info?)->Int32{
        index?.estimatedRows = 1000
        index?.estimatedCost = 1000
        index?.idxNum = 0
        for i in 0..<index!.nConstraint{
          
            index?.aConstraintUsage[Int(i)].argvIndex = i + 1
            index?.aConstraintUsage[Int(i)].omit = 1
        }
        
        return SQLITE_OK
    }
    public func eof(cursor:VTabCursor)->Bool{
        return cursor.rowid > 4
    }
    public func row(cursor:VTabCursor)->sqlite3_int64{
        return sqlite3_int64(cursor.rowid)
    }
    public func colume(cur:VTabCursor,ctx:SQLContext,index:Int32)->Int32{
        
        ctx.ret(v: "\(index)-|-")
        
        return SQLITE_OK
    }
    deinit {
        self.module.deallocate()
        sqlite3_create_module(self.db?.sqlite, self.name, nil, nil)
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
    vt.connect(arg: str, tab: &vtm, error: &error)
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
    vt.create(arg: str, tab: &vtm, error: &error)
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
    let ret = a.pointee.module.bestIndex(tab: a.pointee, index: &info)
    guard let inf = info else { return SQLITE_NOMEM }
    index?.pointee = inf
    return ret
}
func xdisconnect(table:UnsafeMutablePointer<sqlite3_vtab>?)->Int32{
    let a = unsafeBitCast(table, to: UnsafeMutablePointer<VModule.VTab>.self)
    a.pointee.module.disconnect(tab: a.pointee)
    sqlite3_free(table)
    return SQLITE_OK
}
func xopen(table:UnsafeMutablePointer<sqlite3_vtab>?, cursor:UnsafeMutablePointer<UnsafeMutablePointer<sqlite3_vtab_cursor>?>?) -> Int32{
    let a = unsafeBitCast(table, to: UnsafeMutablePointer<VModule.VTab>.self)
    let pointer = sqlite3_malloc64(sqlite3_uint64(MemoryLayout<VModule.VTabCursor>.size))
    var tc = a.pointee.module.open(tab: a.pointee)
    if tc == nil{
        return SQLITE_ERROR
    }
    memcpy(pointer, &tc, MemoryLayout<VModule.VTabCursor>.size);
    cursor?.pointee = unsafeBitCast(pointer, to: UnsafeMutablePointer<sqlite3_vtab_cursor>.self)
    return SQLITE_OK
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
    cur.pointee.argc = Int(argc)
    cur.pointee.idNum = Int(idxNum)
    cur.pointee.idStr = s
    return cur.pointee.table.module.filter(cursor: cur.pointee,ctx: c, valueCount: argc)
}
func xnext(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    return cursor.pointee.table.module.next(cursor: &cursor.pointee)
}
func xeof(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    return cursor.pointee.table.module.eof(cursor: cursor.pointee) ?  1 : 0
}
func xrowid(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?, prowId:UnsafeMutablePointer<sqlite3_int64>?) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    let rowid = cursor.pointee.table.module.row(cursor: cursor.pointee)
    prowId?.pointee = rowid
    return SQLITE_OK
}
func xColumn(cur:UnsafeMutablePointer<sqlite3_vtab_cursor>?, ctx:OpaquePointer?, i:Int32) -> Int32{
    let cursor = unsafeBitCast(cur, to: UnsafeMutablePointer<VModule.VTabCursor>.self)
    let sqlctx = SQLContext()
    sqlctx.ctx = ctx
    return cursor.pointee.table.module.colume(cur: cursor.pointee,ctx: sqlctx, index: i)
}
