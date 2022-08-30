//
//  CokeCompute.swift
//  CokeVideo
//
//  Created by hao yin on 2021/2/24.
//

import Metal
import simd
import MetalPerformanceShaders

public class CokeComputer{
    public var device:MTLDevice{
        self.configuration.device
    }
    public var queue:MTLCommandQueue{
        self.configuration.queue
    }
    
    
    public let configuration:CokeMetalConfiguration
    public init(configuration:CokeMetalConfiguration = CokeMetalConfiguration.defaultConfiguration) {
        self.configuration = configuration
    }
    
    public func compute(name:String,buffer:MTLCommandBuffer,pixelSize:MTLSize? = nil,buffers:[MTLBuffer] = [],textures:[MTLTexture] = []) throws{
        try self.startEncoder(name: name,cmdBuffer: buffer,callback: { (encoder) in
            if(textures.count > 0){
                encoder .setTextures(textures, range: 0 ..< textures.count)
            }
            if(buffers.count > 0){
                encoder.setBuffers(buffers, offsets: (0 ..< buffers.count).map({_ in 0}), range: 0 ..< buffers.count)
            }
            if let gsize = pixelSize{
                let maxX = Int(sqrt(Double(self.device.maxThreadsPerThreadgroup.width)))
                let maxY = Int(sqrt(Double(self.device.maxThreadsPerThreadgroup.height)))
                let x = Int(ceil(Float(gsize.width) / Float(maxX)))
                let y = Int(ceil(Float(gsize.height) / Float(maxY)))
                let s = MTLSize(width: x, height: y, depth: 1)
                encoder.dispatchThreadgroups(s, threadsPerThreadgroup: MTLSize(width: maxX, height: maxY, depth: 1))
                
            }
            encoder.endEncoding()
            
        })
    }
    public func compute(name:String,buffer:MTLCommandBuffer,countOfGrid:UInt = 0,buffers:[MTLBuffer] = [],textures:[MTLTexture] = []) throws{
        try self.startEncoder(name: name,cmdBuffer: buffer,callback: { (encoder) in
            if(textures.count > 0){
                encoder .setTextures(textures, range: 0 ..< textures.count)
            }
            if(buffers.count > 0){
                encoder.setBuffers(buffers, offsets: (0 ..< buffers.count).map({_ in 0}), range: 0 ..< buffers.count)
            }
            if countOfGrid > 0{
                encoder.dispatchThreadgroups(MTLSize(width: Int(countOfGrid), height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
            }
            encoder.endEncoding()
            
        })
    }
    public typealias EncoderBlock = (MTLComputeCommandEncoder) throws ->Void
    public func startEncoder(name:String,cmdBuffer:MTLCommandBuffer,callback:EncoderBlock)throws{
        guard let function = self.configuration.function(name: name) else {
            throw NSError(domain: "can't load function \(name)", code: 0, userInfo: nil)
        }
        let state = try self.device.makeComputePipelineState(function: function)
        guard let encoder = cmdBuffer.makeComputeCommandEncoder() else {
            throw NSError(domain: "you should create command Encoder", code: 0, userInfo: nil)
        }
        encoder.setComputePipelineState(state)
        try callback(encoder)
    }
    public func encoderTexture(encoder:MTLComputeCommandEncoder,textures:[MTLTexture]){
        if textures.count > 0{
            encoder.setTextures(textures, range: 0 ..< textures.count)
        }
    }
    public static var shared:CokeComputer = {CokeComputer()}()
}
public class CokeRender2dContext{
    public let cokeComputer:CokeComputer
    private var texture:MTLTexture?
    public private(set) var ctm:CGAffineTransform = .identity
    public init(width:Int,height:Int){
        self.cokeComputer = CokeComputer()
        self.texture = self.cokeComputer.configuration.createTexture(width: width, height: height, usage:[.shaderRead,.shaderWrite], store: .shared)
    }
    public func setPath(path:CGPath){
        
    }
    public func setColor(color:[Float]){
        
    }
    public func setShadow(radius:Float,offset:CGSize,color:[Float]){
        
    }
    public func fillPath(){
        
    }
}
