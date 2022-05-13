//
//  Module.swift
//  Ammo
//
//  Created by hao yin on 2022/5/13.
//

import Foundation

public enum Memory{
    case Singleton
    case Normal
}

public protocol ModuleEntry{
    var memory:Memory { get }
    var name:String { get }
}

public protocol Module{
    @ModuleBuilder var entries:[String:ModuleEntry] { get }
}

@resultBuilder
public struct ModuleBuilder{
    public static func buildBlock(_ components: ModuleEntry ...) -> [String:ModuleEntry] {
        return components.reduce(into: [:]) { partialResult, me in
            partialResult[me.name] = me
        }
    }
}

