//
//  ImageFilter.swift
//  Ammo
//
//  Created by wenyang on 2022/10/8.
//

import UIKit

public func +<A,B,C>(l:@escaping (A)->B,r:@escaping (B)->C)->(A)->C{
    return { i in
        r(l(i))
    }
}
public func +<C,B>(l:@escaping ()->B,r:@escaping (B)->C)->()->C{
    return {
        r(l())
    }
}
public func curry <A,B,C,D,E,F,G,H>(_ l:@escaping(A,B,C,D,E,F,G)->H)->(A)->(B)->(C)->(D)->(E)->(F)->(G)->H{
    return { a in{ b in{ c in{ d in{ e in{ f in { g in return l(a,b,c,d,e,f,g)}}}}}}}
}
public func curry <A,B,C,D,E,F,G>(_ l:@escaping(A,B,C,D,E,F)->G)->(A)->(B)->(C)->(D)->(E)->(F)->G{
    return { a in{ b in{ c in{ d in{ e in{ f in return l(a,b,c,d,e,f)}}}}}}
}
public func curry <A,B,C,D,E,F>(_ l:@escaping(A,B,C,D,E)->F)->(A)->(B)->(C)->(D)->(E)->F{
    return { a in{ b in{ c in{ d in{ e in return l(a,b,c,d,e)}}}}}
}
public func curry <A,B,C,D,E>(_ l:@escaping(A,B,C,D)->E)->(A)->(B)->(C)->(D)->E{
    return { a in{ b in{ c in{ d in return l(a,b,c,d)}}}}
}
public func curry <A,B,C,D>(_ l:@escaping(A,B,C)->D)->(A)->(B)->(C)->D{
    return { a in{ b in{ c in return l(a,b,c)}}}
}
public func curry <A,B,C>(_ l:@escaping(A,B)->C)->(A)->(B)->C{
    return { a in{ b in return l(a,b)}}
}
