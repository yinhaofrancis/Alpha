//
//  ImageDisplay.swift
//  Ammo
//
//  Created by wenyang on 2022/10/7.
//

import UIKit
import MetalKit
@objc(AMCoreImageView)
public class CoreImageView:UIView{
    private static var dispatchQueue:DispatchQueue = DispatchQueue(label: "CoreImageView")
    public var image:CIImage?{
        didSet{
            if(oldValue?.extent != image?.extent){
                self.invalidateIntrinsicContentSize()
                self.superview?.layoutIfNeeded()
            }
            let bound = self.nativeBound
            let layer = self.mtlayer
            self.render(renderImage: self.image, bound: bound, layer: layer)
            
        }
    }
    private var render = MetalRender.shared
    public var riimage:RIImage?{
        didSet{
            self.image = self.riimage?.primaryImage
        }
    }
    private var renderloop:RenderLoop?

    public override class var layerClass: AnyClass{
        return CAMetalLayer.self
    }

    public var mtlayer:CAMetalLayer{
        return self.layer as! CAMetalLayer
    }

    public func render(renderImage:CIImage?,bound: CGRect,layer:CAMetalLayer){
        guard let img = renderImage else { return }
        if(self.model == nil){
            self.model = MetalRender.Model(image: img, bound: bound, filter: self.displayfilter, target: layer)
        }else{
            self.model?.image = img
            self.model?.bound = bound
            self.model?.filter = self.displayfilter
        }
        guard let md = self.model else { return }
        self.render.prepare(model: md)
    }
    private var model:MetalRender.Model?
    public var nativeBound:CGRect{
        let bound = self.bounds;
        return CGRect(x: 0, y: 0, width: bound.width * UIScreen.main.scale, height: bound.height * UIScreen.main.scale)
    }
    private var displayfilter:ImageDisplayMode = ImageDisplayMode()
    
    public var displayMode:ImageFillMode.DisplayMode{
        get {
            return self.displayfilter.displayMode
        }
        set{
            self.displayfilter.displayMode = newValue
        }
    }
    public override var intrinsicContentSize: CGSize{
        return self.image?.extent.size.applying(CGAffineTransform(scaleX: 1 / UIScreen.main.scale, y:  1 / UIScreen.main.scale)) ?? .zero
    }
}


public class MetalRender{

    public class Model:Hashable{
        public static func == (lhs: MetalRender.Model, rhs: MetalRender.Model) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.target)
        }
        var image:CIImage
        var bound:CGRect
        var filter:ImageRenderModel
        let target:CAMetalLayer
        public init(image:CIImage,bound:CGRect,filter:ImageRenderModel,target:CAMetalLayer){
            self.image = image
            self.bound = bound
            self.filter = filter
            self.target = target
        }
    }
    private var callbuffer:Set<WeakHashProxy<Model>> = Set()
#if targetEnvironment(simulator)
    private var trans:ImageAffine = ImageAffine(type: .Transform)
#endif
    private func transformFilter(img:CIImage,bound:CGRect,filter:ImageRenderModel)->CIImage?{
        guard let result = filter.filter(img: img, bound: bound) else { return nil }
#if targetEnvironment(simulator)
        return trans.filter(transform: CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -img.extent.height), image: result)
#else
        return result
#endif
    }
    private func render(img:CIImage,bound:CGRect,filter:ImageRenderModel,target:CAMetalLayer){
        target.device = MetalRender.device
        target.pixelFormat = .bgra8Unorm
        target.framebufferOnly = false
        target.colorspace = CGColorSpaceCreateDeviceRGB()
        target.contentsScale = UIScreen.main.scale
        target.drawableSize = bound.size
        guard let buffer = self.buffer else { return }
        guard let result = self.transformFilter(img: img, bound: bound, filter: filter) else { return }
        guard let ctx = self.ctx else { return }
        guard let drawable = target.nextDrawable() else { return }
        ctx.render(result, to: drawable.texture, commandBuffer: buffer, bounds:bound, colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer.present(drawable)
        buffer.commit()
        buffer.waitUntilCompleted()
    }
    public func renderOffscreen(img:CIImage)->CGImage?{
        guard let ctx = self.ctx else { return nil }
        return ctx.createCGImage(img, from: img.extent)
    }
    private var buffer:MTLCommandBuffer?{
        MetalRender.queue?.makeCommandBuffer()
    }
    private static var queue:MTLCommandQueue? = {
        device?.makeCommandQueue()
    }()
    private lazy var ctx:CIContext? = {
        guard let queue = MetalRender.queue else {
            return nil
        }
        guard let device = MetalRender.device else{
            return nil
        }
        if #available(iOS 13.0, *) {
            return CIContext(mtlCommandQueue: queue)
        } else {
            return CIContext(mtlDevice: device)
        }
    }()
    private static var device:MTLDevice? = MTLCreateSystemDefaultDevice()
    
    public static var shared:MetalRender {
        if let mr = sharedMetalRender.content{
            return mr
        }
        let mr =  MetalRender()
        self.sharedMetalRender.content = mr
        return mr
    }
    private static let sharedMetalRender:WeakProxy<MetalRender> = WeakProxy(content: nil)
    
    public var renderLoop:RenderLoop?
    public func prepare(model:Model){
        self.renderLoop?.runloop?.perform {
            if !self.contains(model: model){
                self.callbuffer.insert(WeakHashProxy(content: model))
            }
        }
    }
    func contains(model:Model)->Bool{
        self.callbuffer.contains(WeakHashProxy(content: model))
    }
    public init(){
        self.renderLoop = RenderLoop(callback: { [weak self] i in
            guard let ws = self else { i.stop();return  }
            for i in ws.callbuffer {
                guard let c = i.content else { continue }
                ws.render(img: c.image, bound: c.bound, filter: c.filter, target: c.target)
            }
            ws.callbuffer.removeAll()
        })
        self.renderLoop?.start()
    }
}


public class RenderLoop:NSObject{
    private lazy var thread:Thread = {
        return Thread {[weak self] in
            if(self?.runloop == nil){
                self?.runloop = RunLoop.current
                _ = self?.link
                self?.runloop?.run()
            }
        }
    }()
    public lazy var link:CADisplayLink = {
        let link = CADisplayLink(target: self, selector: #selector(callbackFunc))
        self.loadRate(rate: self.rate, link: link)
        if let runloop = self.runloop{
            link.add(to: runloop, forMode: .default)
        }
        return link
    }()
    public func start(main:Bool = false){
        if(main){
            self.runloop = RunLoop.main
            _ = self.link
        }else{
            self.thread.start()
        }
        
    }
    public var rate:Float = 60{
        didSet{
            self.loadRate(rate: self.rate, link: self.link)
        }
    }
    private func loadRate(rate:Float,link:CADisplayLink){
        if #available(iOSApplicationExtension 15.0, *) {
            link.preferredFrameRateRange = CAFrameRateRange(minimum: rate, maximum: rate)
        } else {
            link.preferredFramesPerSecond = Int(rate)
        }
    }
    public var callback:(RenderLoop)->Void
    public init(callback:@escaping (RenderLoop)->Void){
        self.callback = callback
    }
    @objc public func callbackFunc(){
        self.callback(self)
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
