//
//  ImageDisplay.swift
//  Ammo
//
//  Created by wenyang on 2022/10/7.
//

import UIKit
import MetalKit

public class CoreImageView:UIView{

    public var image:CIImage?{
        didSet{
            self.invalidateIntrinsicContentSize()
            self.render()
        }
    }
    public var uiImage:UIImage?{
        didSet{
            guard let im = uiImage else { self.image = nil;return }
            self.image = CIImage(image: im)
        }
    }
    public override class var layerClass: AnyClass{
        return CAMetalLayer.self
    }

    public var mtlayer:CAMetalLayer{
        return self.layer as! CAMetalLayer
    }

    public func render(){
        guard let img = self.image else { return }
        MetalRender.shared.render(img: img, bound: self.nativeBound, filter: self.displayfilter, target: self.mtlayer)
    }
    public var nativeBound:CGRect{
        let bound = self.bounds;
        return CGRect(x: 0, y: 0, width: bound.width * UIScreen.main.scale, height: bound.height * UIScreen.main.scale)
    }
    private var displayfilter:ImageRenderModel = DisplayModeFilter()
}


public class MetalRender{

    public var callbuffer:[()->Void] = []
    public func render(img:CIImage,bound:CGRect,filter:ImageRenderModel,target:CAMetalLayer){
        target.device = self.device
        target.pixelFormat = .bgra8Unorm_srgb
        target.framebufferOnly = false
        target.colorspace = CGColorSpaceCreateDeviceRGB()
        target.contentsScale = UIScreen.main.scale
        self.dispatchQueue.async {
            guard let buffer = self.buffer else { return }
            guard let result = filter.filter(img: img, bound: bound) else { return }
            guard let ctx = self.ctx else { return }
            guard let drawable = target.nextDrawable() else { return }
            ctx.render(result, to: drawable.texture, commandBuffer: buffer, bounds: bound, colorSpace: CGColorSpaceCreateDeviceRGB())
            buffer.present(drawable)
            buffer.commit()
            buffer.waitUntilCompleted()
        }
    }
 
    private var buffer:MTLCommandBuffer?{
        self.queue?.makeCommandBuffer()
    }
    private lazy var queue:MTLCommandQueue? = {
        device?.makeCommandQueue()
    }()
    private lazy var ctx:CIContext? = {
        guard let queue = queue else {
            return nil
        }
        return CIContext(mtlCommandQueue: queue)
    }()
    private var device:MTLDevice? = MTLCreateSystemDefaultDevice()
    private var dispatchQueue:DispatchQueue = { DispatchQueue(label: "CoreImageView")}()
    
    public static let shared:MetalRender = MetalRender()
    private var runloop:RunLoop?
    private lazy var thread:Thread = {
        Thread {[weak self] in
            self?.runloop = RunLoop.current
            RunLoop.current.run()
        }
    }()
    @objc func run(){
        
    }
    public lazy var link:CADisplayLink? =  {
        let link = CADisplayLink(target: self, selector: #selector(run))
        if #available(iOS 15.0, *) {
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: 60)
        } else {
            // Fallback on earlier versions
            link.preferredFramesPerSecond = 10
        }
        guard let runloop = runloop else {
            return nil
        }
        link.add(to: runloop, forMode: .default)
        return link
    }()
}
