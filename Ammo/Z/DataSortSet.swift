//
//  DataSortSet.swift
//  Ammo
//
//  Created by hao yin on 2022/8/23.
//

import Foundation

public class DataSortSet<T>{
    private var dataMap:[Int:T] = [:]
    private var holeRange:[ClosedRange<Int>] = []
    private var maxIndex:Int = -1
    public func insert(index:Int,content:T){
        self.dataMap[index] = content
        if(index - maxIndex > 1){
            holeRange.append((maxIndex + 1) ... (index - 1))
        } else if(index < maxIndex){
            for i in 0 ..< holeRange.count{
                if self.holeRange[i].contains(index){
                    
                    let oldRange = self.holeRange[i]
                    
                    if(oldRange.lowerBound == index && oldRange.upperBound > oldRange.lowerBound){
                        self.holeRange[i] = index + 1 ... oldRange.upperBound
                        break;
                    }else if (oldRange.upperBound == index && oldRange.upperBound > oldRange.lowerBound){
                        self.holeRange[i] = oldRange.lowerBound ... index - 1
                        break;
                    }else if (oldRange.upperBound > oldRange.lowerBound){
                        self.holeRange[i] = oldRange.lowerBound ... index - 1
                        self.holeRange.append(index + 1 ... oldRange.upperBound)
                        break;
                    }else{
                        self.holeRange.remove(at: i)
                        break;
                    }
                }
            }
        }
        self.maxIndex = max(index, self.maxIndex)
    }
    public var holes:[ClosedRange<Int>]{
        self.holeRange.sorted { l, r in
            l.upperBound < r.upperBound
        }
    }
    public init(){}
    public var data:[T]{
        self.dataMap.sorted { l, r in
            l.key < r.key
        }.map { v in
            return v.value
        }
        
    }
}
