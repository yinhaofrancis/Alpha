//
//  ImageDisplay.swift
//  Ammo
//
//  Created by wenyang on 2022/10/7.
//

import UIKit
import MetalKit

public class CoreImageView:UIView{

    private static var dispatchQueue:DispatchQueue = DispatchQueue(label: "CoreImageView")
    public var image:CIImage?{
        didSet{
            self.invalidateIntrinsicContentSize()
            self.superview?.layoutIfNeeded()
            let bound = self.nativeBound
            let layer = self.mtlayer
            CoreImageView.dispatchQueue.async {
                self.render(renderImage: self.image, bound: bound, layer: layer)
            }
            
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

    public func render(renderImage:CIImage?,bound: CGRect,layer:CAMetalLayer){
        guard let img = renderImage else { return }
        MetalRender.shared.render(img: img, bound: bound, filter: self.displayfilter, target: layer)
    }
    public var nativeBound:CGRect{
        let bound = self.bounds;
        return CGRect(x: 0, y: 0, width: bound.width * UIScreen.main.scale, height: bound.height * UIScreen.main.scale)
    }
    private var displayfilter:ImageRenderModel = ImageDisplayMode()
    
    
    public override var intrinsicContentSize: CGSize{
        return self.image?.extent.size.applying(CGAffineTransform(scaleX: 1 / UIScreen.main.scale, y:  1 / UIScreen.main.scale)) ?? .zero
    }
}


public class MetalRender{

    public var callbuffer:[()->Void] = []
    public func render(img:CIImage,bound:CGRect,filter:ImageRenderModel,target:CAMetalLayer){
        target.device = self.device
        target.pixelFormat = .bgra8Unorm
        target.framebufferOnly = false
        target.colorspace = CGColorSpaceCreateDeviceRGB()
        target.contentsScale = UIScreen.main.scale
        target.drawableSize = bound.size
        guard let buffer = self.buffer else { return }

        guard let result = filter.filter(img: img, bound: bound) else { return }
        guard let ctx = self.ctx else { return }
        guard let drawable = target.nextDrawable() else { return }
        ctx.render(result, to: drawable.texture, commandBuffer: buffer, bounds: bound, colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer.present(drawable)
        buffer.commit()
        buffer.waitUntilCompleted()
    }
    public func renderOffscreen(img:CIImage)->CGImage?{
        guard let ctx = self.ctx else { return nil }
        return ctx.createCGImage(img, from: img.extent)
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
    
    public static let shared:MetalRender = MetalRender()
}

public class RenderLoop:NSObject{
    public lazy var thread:Thread = {
        return Thread {[weak self] in
            self?.runloop = RunLoop.current
            _ = self?.link
            self?.runloop?.run()
        }
    }()
    public lazy var link:CADisplayLink = {
        let link = CADisplayLink(target: self, selector: #selector(callbackFunc))
        if let runloop = self.runloop{
            link.add(to: runloop, forMode: .default)
        }
        return link
    }()
    public func start(){
        self.thread.start()
    }
    public var callback:()->Void
    public init(callback:@escaping ()->Void){
        self.callback = callback
    }
    @objc public func callbackFunc(){
        self.callback()
    }
    deinit {
        self.stop()
    }
    public func stop(){
        self.link.invalidate()
        if let rl = self.runloop?.getCFRunLoop(){
            CFRunLoopStop(rl)
        }
        self.thread.cancel()
    }
    public var runloop:RunLoop?
}
