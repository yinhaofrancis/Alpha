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
