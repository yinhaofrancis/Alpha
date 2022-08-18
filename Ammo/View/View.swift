//
//  View.swift
//  Ammo
//
//  Created by hao yin on 2022/8/18.
//

import Foundation
import QuartzCore

public protocol View{
    var frame:CGRect { get set }
    
    var radius:CGFloat { get set }
    
    var layer:CGLayer? { get }
    
    func drawLayer(context:RenderContext)
    
    func setNeedDisplay()
    
    func render(ctx:RenderContext)
    
    var subViews:[View] { get }
    
    func addSubView(view:View)
    
    var shadowRadius:CGFloat { get set }
    
    var shadowOffset:CGSize { get set }
    
    var shadowColor:CGColor? { get set }
    
    var clip:Bool { get }
    
    var content:FillContent? { get set }
}

public protocol FillContent{
    func draw(context:RenderContext,path:CGPath)
}
extension CGColor:FillContent{
    public func draw(context: RenderContext, path: CGPath) {
        context.begin { rc in
            rc.context.setFillColor(self)
            rc.context.addPath(path)
            rc.context.fillPath()
        }
        
        
    }
}
public struct ImageFillContent:FillContent{
    public var image:CGImage?
    public var offset:CGPoint = .zero
    public init(image:CGImage?,offset:CGPoint = .zero){
        self.image = image
        self.offset = offset
    }
    public func draw(context: RenderContext, path: CGPath) {
        context.begin { rc in
            rc.context.addPath(path)
            rc.context.clip()
            rc.context.scaleBy(x: 1, y: -1)

            guard let image = image else {
                return
            }
            rc.context.draw(image, in: CGRect(origin: self.offset, size: context.imageSize(image: image)), byTiling: true)
        }
    }
}
public class RenderView:View{
    
    public var clip: Bool = true

    public var shadowRadius: CGFloat = 0
    
    public var shadowOffset: CGSize = .zero
    
    public var shadowColor: CGColor?
    
    public var radius: CGFloat = 0
 
    public func addSubView(view: View) {
        self.subViews.append(view)
    }
    public var subViews: [View] = []
    
    public var parentView: View?
    
    public func setNeedDisplay() {
        self.contentLayer = nil
    }
    
    public var frame: CGRect{
        didSet{
            if(frame.size != oldValue.size){
                self.setNeedDisplay()
            }
        }
    }
    
    public var layer: CGLayer?{
        if(contentLayer == nil){
            self.createLayer()
        }
        return contentLayer
    }
    
    private var contentLayer:CGLayer?
    
    public func drawLayer(context: RenderContext) {
        guard let content = self.content else { return }
        content.draw(context: context, path: self.boundPath)
    }
    private var boundPath:CGPath{
        CGPath(roundedRect: self.bound, cornerWidth: self.radius, cornerHeight: self.radius, transform: nil)
    }
    private var framePath:CGPath{
        CGPath(roundedRect: self.frame, cornerWidth: self.radius, cornerHeight: self.radius, transform: nil)
    }
    
    private func createLayer(){
        self.contentLayer = self.context.createLayer(size: self.frame.size)
        guard let ctx = self.contentLayer?.context else { return }
        self.drawLayer(context: RenderContext(ctx:ctx , scale: self.context.scale))
    }
    
    
    public var bound:CGRect{
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    private var context:RenderContext

    public var content: FillContent?{
        didSet{
            self.setNeedDisplay()
        }
    }
    
    public init(frame:CGRect,context:RenderContext){
        self.frame = frame
        self.context = context
    }
    public func render(ctx:RenderContext){
        ctx.begin { ctx in
            guard let layer = layer else {
                return
            }
            ctx.context.setShadow(offset: self.shadowOffset, blur: self.shadowRadius, color: self.shadowColor)
            ctx.context.draw(layer, in: self.frame)
            if(self.clip){
                ctx.context.addPath(self.framePath)
                ctx.context.clip()
            }
            ctx.begin { rc in
                rc.context.translateBy(x: self.frame.origin.x, y: self.frame.origin.y)
                for i in self.subViews {
                    i.render(ctx: rc)
                }
            }
        }
    }
}

public class RenderTextView:RenderView{
    public var alignX:CGFloat = 0.5
    public var alignY:CGFloat = 0.5
    public var attributedString:CFAttributedString?
    public override func drawLayer(context: RenderContext) {
        super.drawLayer(context: context)
        guard let attributedString = attributedString else {
            return
        }
        context.drawString(string:attributedString , constaint: self.bound, alignX: self.alignX, AlignY: self.alignY)
    }
}
public class RenderImageView:RenderView{
    public var image:CGImage?
    public var mode:DrawImageMode = .scale
    public override func drawLayer(context: RenderContext) {
        super.drawLayer(context: context)
        guard let image = image else {
            return
        }
        context.drawScaleImage(image: image, rect: self.bound, mode: self.mode)
    }
    public init(image:CGImage,position:CGPoint, context: RenderContext) {
        self.image = image
        super.init(frame: CGRect(origin: position, size: context.imageSize(image: image)), context: context)
    }
    
}
