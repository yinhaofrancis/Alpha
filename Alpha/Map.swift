//
//  Map.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/18.
//

import Foundation

public class Map<K:Hashable,V>{
    private var dic:Dictionary<K,V> = Dictionary()
    private var rw:UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)
    
    public init(){
        pthread_rwlock_init(self.rw, nil)
    }
    public subscript(key:K)->V?{
        get{
            pthread_rwlock_rdlock(self.rw)
            let n = dic
            pthread_rwlock_unlock(self.rw)
            return n[key]
        }
        set{
            pthread_rwlock_wrlock(self.rw)
            self.dic[key] = newValue
            pthread_rwlock_unlock(self.rw)
        }
    }
    deinit {
        pthread_rwlock_destroy(self.rw)
        self.rw.deallocate()
    }
    public func clean(){
        pthread_rwlock_wrlock(self.rw)
        self.dic.removeAll()
        pthread_rwlock_unlock(self.rw)
    }
}
public class List<K:Hashable>{
    private var array = Array<K>()
    private var rw:UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)
    public init(){
        pthread_rwlock_init(self.rw, nil)
    }
    public subscript(key:Int)->K?{
        pthread_rwlock_rdlock(self.rw)
        let n = array
        pthread_rwlock_unlock(self.rw)
        if key >= n.count{
            return nil
        }
        return n[key]
    }
    public func append(element:K){
        pthread_rwlock_wrlock(self.rw)
        self.array.append(element)
        pthread_rwlock_unlock(self.rw)
    }
    public func remove(element:K){
        pthread_rwlock_wrlock(self.rw)
        self.array.removeAll { e in
            e == element
        }
        pthread_rwlock_unlock(self.rw)
    }
    @discardableResult
    public func removeFirst()->K?{
        pthread_rwlock_wrlock(self.rw)
        let a = self.array.count > 0 ? self.array.removeFirst() : nil
        pthread_rwlock_unlock(self.rw)
        return a
    }
    @discardableResult
    public func removeLast()->K?{
        pthread_rwlock_wrlock(self.rw)
        let a = self.array.count > 0 ?  self.array.removeLast() : nil
        pthread_rwlock_unlock(self.rw)
        return a
    }
    deinit {
        pthread_rwlock_destroy(self.rw)
        self.rw.deallocate()
    }
    public func clean(){
        pthread_rwlock_wrlock(self.rw)
        self.array.removeAll()
        pthread_rwlock_unlock(self.rw)
    }
    public var count:Int{
        pthread_rwlock_wrlock(self.rw)
        let c = self.array.count
        pthread_rwlock_unlock(self.rw)
        return c
    }
}
public class BTree<T:Equatable>:CustomStringConvertible{
    public func lock(call:()->Void){
        pthread_mutex_lock(self.lock)
        call()
        pthread_mutex_unlock(self.lock)
    }
    public func lockAccess(call:()->T)->T{
        pthread_mutex_lock(self.lock)
        let r = call()
        pthread_mutex_unlock(self.lock)
        return r
        
    }
    public var description: String{
        return self.array.description
    }

    private var array:Array<T> = Array()
    public private(set) var lock:UnsafeMutablePointer<pthread_mutex_t> = .allocate(capacity: 1)
    public init() {
        pthread_mutex_init(self.lock, nil)
    }
    deinit {
        pthread_mutex_destroy(self.lock)
        self.lock.deallocate()
    }
    public struct Node:Equatable{
        var index:Int
        public var leftNode:Node{  Node(index: index * 2 + 1) }
        public var rightNode:Node{ Node(index: index * 2 + 2) }
        public var parent:Node{ Node(index: index % 2 == 0 ? (index - 2) / 2 : (index - 1) / 2) }
        public var root:Bool{ self.index == 0 }
        public func hash(into hasher: inout Hasher) {
            hasher.combine(index)
        }
        public static func == (lhs: Node, rhs: Node) -> Bool{
            lhs.index == rhs.index
        }
    }
    public subscript(index:Node)->T{
        get{
            let temp = array[index.index]
            return temp
        }
        set{
            self.array[index.index] = newValue
        }
    }
    public func append(object:T){
        self.array.append(object)
    }
    public func removelast(){
        if array.count > 0{
            array.removeLast()
        }

    }
    public func index(content:T)->Node?{
        guard let index = self.array.firstIndex(of: content) else { return nil }
        return Node(index: index)
    }
    public func remove(node:Node){
     
        self.array.remove(at: node.index)
      
    }
    public func isEmpty(index:Node)->Bool{
 
        let temp = index.index >= self.array.count
  
        return temp
    }
    public func isLeaf(index:Node)->Bool{
      
        let temp = self.isEmpty(index: index.leftNode) && self.isEmpty(index: index.rightNode)
     
        return temp
    }
    public var lastNode:Node{
        Node(index: self.array.count - 1)
    }
    public var firstNode:Node{
        Node(index: 0)
    }
    public func removeLastLeaf(count:Int)->ArraySlice<T>{
    
        if array.count == 0 || count > array.count{
            return []
        }
        let r = array[(array.count - count) ..< array.count]
        array.removeSubrange((array.count - count) ..< array.count)
        
        return r
    }
    public var count:Int{
        return self.array.count
    }
}
public class Heap<T:Comparable>:BTree<T>{
    private var compare:(_ lfs:T,_ rfs:T)->Bool
    public init(compare:@escaping (_ lfs:T,_ rfs:T)->Bool){
        self.compare = compare
    }
    public func insert(object:T){
        self.lock{
            self.append(object: object)
            var current = self.lastNode
            var parent = current.parent
            if(current != self.firstNode){
                var parentV = self[parent]
                while compare(parentV,object) && current != self.firstNode{
                    
                    self[parent] = self[current]
                    self[current] = parentV
                    current = parent
                    parent = current.parent
                    if parent.index < 0 || self.count == 0{
                        break
                    }
                    parentV = self[parent]
                }
            }
        }
    }
    public func remove()->T {
        self.remove(node: self.firstNode)
    }
    public func remove(node:Node)->T{
        return self.lockAccess {
            let result = self[node]
            let last = self[self.lastNode]
            self.removelast()
            if(self.count == 0){
                return result
            }
            self[node] = last
            var current = node
            var l = current.leftNode
            var r = current.rightNode
            
            while !self.isEmpty(index: l) || !self.isEmpty(index: r) {
                if !self.isEmpty(index: l) && !self.isEmpty(index: r){
                    if self.compare(self[r],self[l]){
                        if self.compare(self[current],self[l]){
                            let pv = self[current]
                            let lv = self[l]
                            self[l] = pv
                            self[current] = lv
                            current = l
                            l = current.leftNode
                            r = current.rightNode
                            continue
                        }
                    }else{
                        if self.compare(self[current],self[r]){
                            let pv = self[current]
                            let rv = self[r]
                            self[r] = pv
                            self[current] = rv
                            current = r
                            l = current.leftNode
                            r = current.rightNode
                            continue
                        }
                    }
                }else if !self.isEmpty(index: l){
                    if self.compare(self[current],self[l]){
                        let pv = self[current]
                        let lv = self[l]
                        self[l] = pv
                        self[current] = lv
                        current = l
                        l = current.leftNode
                        r = current.rightNode
                        continue
                    }
                }else if !self.isEmpty(index: r){
                    if self.compare(self[current],self[r]){
                        let pv = self[current]
                        let rv = self[r]
                        self[r] = pv
                        self[current] = rv
                        current = r
                        l = current.leftNode
                        r = current.rightNode
                        continue
                    }
                }
                break
            }
            
            return result
        }
    }
}
public class MaxHeap<T:Comparable>:Heap<T>{
    public init(){
        super.init(compare: {$0<$1})
    }
}
public class MinHeap<T:Comparable>:Heap<T>{
    public init(){
        super.init(compare: {$0>$1})
    }
}
public protocol MemorySizeAble{
    var memorySize:Int64 { get }
}
public class Priority<T:Equatable & MemorySizeAble>:Comparable{
    public static func == (lhs: Priority<T>, rhs: Priority<T>) -> Bool {
        lhs.count == rhs.count
    }
    public init(content:T,name:String) {
        self.content = content
        self.name = name
    }
    public var content:T
    public var count:Int = 1
    public var date:Date = Date()
    public var name:String
    public static func < (lhs: Priority<T>, rhs: Priority<T>) -> Bool {
        if(rhs.count > lhs.count){
            return true
        }else if(rhs.count == lhs.count){
            if(rhs.date > lhs.date){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}

extension Data:MemorySizeAble {
    public var memorySize: Int64 {
        Int64(self.count)
    }
}
extension Int:MemorySizeAble{
    public var memorySize: Int64{
        #if arch(arm64)
            return 8
        #elseif arch(x86_64)
            return 8
        #else
            return 4
        #endif
    }
}
extension Int32:MemorySizeAble{
    public var memorySize: Int64{
        return 4
    }
}
extension Int64:MemorySizeAble{
    public var memorySize: Int64{
        return 8
    }
}

public class LinkBTree<T:Equatable>{
    
}
