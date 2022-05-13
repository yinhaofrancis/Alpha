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
//    public static func buildBlock(_ components: [String:ModuleEntry] ...) -> [String:ModuleEntry] {
//        return components.reduce(into: [:]) { partialResult, me in
//            for i in me{
//                partialResult[i.key] = i.value
//            }
//        }
//    }
//    public static func buildArray(_ components: [[String:ModuleEntry]]) -> [String:ModuleEntry] {
//        return components.reduce(into: [:]) { partialResult, me in
//            for i in me{
//                partialResult[i.key] = i.value
//            }
//        }
//    }
    public static func buildArray(_ components: ModuleEntry...) -> [String:ModuleEntry] {
        return components.reduce(into: [:]) { partialResult, me in
            partialResult[me.name] = me
        }
    }
//    public static func buildEither(first component: [String:ModuleEntry]) -> [String:ModuleEntry] {
//        return component
//    }
//    public static func buildEither(second component: [String:ModuleEntry]) -> [String:ModuleEntry] {
//        return component
//    }
//    public static func buildEither(first component: ModuleEntry) -> [String:ModuleEntry] {
//        return [component.name:component]
//    }
//    public static func buildEither(second component: ModuleEntry) -> [String:ModuleEntry] {
//        return [component.name:component]
//    }
}

