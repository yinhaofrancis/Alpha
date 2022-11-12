//
//  Squeue.swift
//  butterfly
//
//  Created by wenyang on 2022/11/4.
//

import Foundation

public enum MemeoryType{
    case singlton
    case weakSinglton
    case new
}

public class WeakContent<T:AnyObject>{
    weak var content:T?
    public init(content: T? = nil) {
        self.content = content
    }
}


public class RWDictionary<Key, Value> where Key : Hashable{
    var _content:Dictionary<Key,Value> = [:]
    public var content: Dictionary<Key,Value> {
        get{
            pthread_rwlock_rdlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            return self._content
        }
        set{
            pthread_rwlock_wrlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            self._content = newValue
        }
    }
    public func merge(dic:Dictionary<Key,Value>){
        self._content.merge(dic) { a, b in
            return b
        }
    }
    
    public var lock:pthread_rwlock_t = pthread_rwlock_t()
    
    public subscript(key:Key)->Value?{
        get{
            pthread_rwlock_rdlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            return self._content[key]
        }
        set{
            pthread_rwlock_wrlock(&self.lock)
            defer{
                pthread_rwlock_unlock(&self.lock)
            }
            self._content[key] = newValue
        }
    }
    public init(content:Dictionary<Key,Value>) {
        pthread_rwlock_init(&self.lock, nil)
        self._content = content
    }
    public init() {
        pthread_rwlock_init(&self.lock, nil)
    }
    deinit{
        pthread_rwlock_destroy(&self.lock)
    }
}
