//
//  CokeRender.swift
//  Ammo
//
//  Created by hao yin on 2022/8/30.
//

import Metal
import simd
import QuartzCore
import CoreImage

public struct CokeRenderState{
    public var tranform:matrix_float3x3
}

public struct DrawState{
    public var sum:Float
}

public class CokeRender2d{
    public var width:Int
    
    public var height:Int
    public let scale:Float
    
    public let computer:CokeComputer
    public let texture:MTLTexture
    public var commandBuffer:MTLCommandBuffer?
    public var state:CokeRenderState
    public init(width:Int,height:Int,computer:CokeComputer = CokeComputer.shared) throws {
        self.computer = computer
        self.width = width
        self.height = height
        guard let t = computer.configuration.createTexture(width: width, height: height) else { throw NSError(domain: "create context error", code: 0) }
        self.texture = t
        let scale:Float = 3
        self.scale = scale
        self.state = CokeRenderState(tranform: matrix_float3x3([scale,0,0], [0,scale,0], [0,0,scale]))
    }
    public init(texture:MTLTexture,computer:CokeComputer = CokeComputer.shared) throws {
        self.computer = computer
        self.width = texture.width
        self.height = texture.height
        self.texture = texture
        let scale:Float = 3
        self.scale = scale
        self.state = CokeRenderState(tranform: matrix_float3x3([scale,0,0], [0,scale,0], [0,0,scale]))
    }
    public func begin() throws{
        self.commandBuffer = try self.computer.configuration.begin()
    }
    private func getCommandBuffer() throws ->MTLCommandBuffer{
        guard let bf = self.commandBuffer else { throw NSError(domain: "no buffer", code: 0) }
        return bf
    }
    public func commit(){
        guard let bf = self.commandBuffer else { return }
        self.computer.configuration.commit(buffer: bf)
    }
    public func compute(name:String,count:UInt,buffers:[MTLBuffer] = [],textures:[MTLTexture] = []) throws{
        guard let b1 = self.computer.configuration.createBuffer(data: self.state) else { throw NSError(domain: "create state fail", code: 0)}
        guard let b2 = self.computer.configuration.createBuffer(data: DrawState(sum: Float(count))) else { throw NSError(domain: "create state fail", code: 0) }
        var bfs = buffers
        bfs.append(b1)
        bfs.append(b2)
        try self.computer.compute(name: name, buffer: try self.getCommandBuffer(), countOfGrid: count + 1, buffers: bfs, textures: textures)
    }
    public func present(drawble:MTLDrawable){
        guard let bf = self.commandBuffer else { return }
        bf.present(drawble)
    }
    public func createCIImage()->CIImage?{
        self.computer.configuration.createCIImage(texture: self.texture)
    }
}
