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

public class CokeRender2d{
    public var width:Int
    
    public var height:Int
    
    
    public let computer:CokeComputer
    public let texture:MTLTexture
    public var commandBuffer:MTLCommandBuffer?
    public init(width:Int,height:Int,computer:CokeComputer = CokeComputer.shared) throws {
        self.computer = computer
        self.width = width
        self.height = height
        guard let t = computer.configuration.createTexture(width: width, height: height) else { throw NSError(domain: "create context error", code: 0) }
        self.texture = t
    }
    public init(texture:MTLTexture,computer:CokeComputer = CokeComputer.shared) throws {
        self.computer = computer
        self.width = texture.width
        self.height = texture.height
        self.texture = texture
    }
    public func drawLine(point1:CGPoint,point2:CGPoint) throws{
        
        let databuffer = self.computer.configuration.createBuffer(data: [SIMD2<Float>(x: Float(point1.x), y: Float(point1.y)),SIMD2<Float>(x: Float(point2.x), y: Float(point2.y))]);
        let d = max(width, height);
        try self.computer.compute(name: "linearBezier", buffer: try self.getCommandBuffer(), countOfGrid: UInt(d), buffers: [databuffer!], textures: [self.texture])
    }
    public func drawQuadraticBezier(point1:CGPoint,point2:CGPoint,point3:CGPoint) throws{
        
        let databuffer = self.computer.configuration.createBuffer(data: [
            SIMD2<Float>(x: Float(point1.x), y: Float(point1.y)),
            SIMD2<Float>(x: Float(point2.x), y: Float(point2.y)),
            SIMD2<Float>(x: Float(point3.x), y: Float(point3.y)),]);
        let d = max(width, height) * 2;
        try self.computer.compute(name: "quadraticBezier", buffer: try self.getCommandBuffer(), countOfGrid: UInt(d), buffers: [databuffer!], textures: [self.texture])
    }
    
    
    public func drawCubicBezier(point1:CGPoint,point2:CGPoint,point3:CGPoint,point4:CGPoint) throws{
        
        let databuffer = self.computer.configuration.createBuffer(data: [
            SIMD2<Float>(x: Float(point1.x), y: Float(point1.y)),
            SIMD2<Float>(x: Float(point2.x), y: Float(point2.y)),
            SIMD2<Float>(x: Float(point3.x), y: Float(point3.y)),
            SIMD2<Float>(x: Float(point4.x), y: Float(point4.y)),]);
        let d = max(width, height) * 3;
        try self.computer.compute(name: "cubicBezier", buffer: try self.getCommandBuffer(), countOfGrid: UInt(d), buffers: [databuffer!], textures: [self.texture])
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
    public func present(drawble:MTLDrawable){
        guard let bf = self.commandBuffer else { return }
        bf.present(drawble)
    }
    public func createCIImage()->CIImage?{
        self.computer.configuration.createCIImage(texture: self.texture)
    }
}
