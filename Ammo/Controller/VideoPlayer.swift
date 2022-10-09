//
//  VideoPlayer.swift
//  Ammo
//
//  Created by wenyang on 2022/10/9.
//

import AVFoundation
import CoreImage
import UIKit

public protocol VideoViewDelegate:AnyObject{
    func videoPixelCallBack(source: CIImage,bound:CGRect) -> CIImage?
    
    func imagePixelCallBack(source: CIImage,bound:CGRect) -> CIImage?
}
public class VideoHasBackgroundView:UIView,VideoViewDelegate{
    public func videoPixelCallBack(source: CIImage, bound: CGRect) -> CIImage? {
        self.delegate?.videoPixelCallBack(source: source, bound: bound)
    }
    
    public func imagePixelCallBack(source: CIImage, bound: CGRect) -> CIImage? {
        return nil
    }
    
    public weak var delegate:VideoViewDelegate?
    public var player:AVPlayer?{
        didSet{
            self.video.player = player
        }
    }
    
    public var video:VideoView = VideoView()
    public var imageBackground:UIImageView = UIImageView()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(self.imageBackground)
        self.addSubview(self.video)
        self.sendSubviewToBack(self.video)
        self.sendSubviewToBack(self.imageBackground)
        self.video.isOpaque = false;
        self.imageBackground.frame = self.bounds
        self.video.frame = self.bounds
        self.video.delegate = self
        guard let image = self.image else { return }
        self.image = image
    }
    public var image:CIImage?{
        didSet{
            guard let image = image else {
                self.imageBackground.image = nil
                return
            }
            guard let ci = self.delegate?.imagePixelCallBack(source: image, bound: self.video.nativeBound) else { return }
            guard let cgi = MetalRender.shared.renderOffscreen(img: ci) else {
                self.imageBackground.image = nil
                return
            }
            self.imageBackground.image = UIImage(cgImage:cgi)
        }
    }
}
public class VideoView:CoreImageView{
    public override var image: CIImage?{
        didSet{
            let displayBound:CGRect = self.nativeBound
            let displayer:CAMetalLayer = self.mtlayer
            if let img = self.image{
                let result = self.delegate?.imagePixelCallBack(source: img, bound: displayBound)
                self.render(renderImage: result, bound: displayBound, layer: displayer)
            }
        }
    }
    
    public weak var delegate:VideoViewDelegate?
    
    public var player:AVPlayer?{
        didSet{
            if player != nil{
                self.createLink()
            }else{
                self.link = nil
            }
        }
    }
    
    private let output: AVPlayerItemVideoOutput
    
    private var link:RenderLoop?
    
    private weak var currentItem:AVPlayerItem?
    
    private func createLink(){
        let displayBound:CGRect = self.nativeBound
        let displayer:CAMetalLayer = self.mtlayer
        self.link = RenderLoop {[weak self] in
            guard let ws = self else { return }
            if(ws.currentItem == nil && ws.player?.currentItem != nil){
                ws.currentItem = ws.player?.currentItem
                ws.currentItem?.add(ws.output)
            }
            if(ws.currentItem != nil && ws.player?.currentItem == nil){
                ws.currentItem = nil
            }
            guard let time = ws.player?.currentItem?.currentTime() else { return }
            if ws.output.hasNewPixelBuffer(forItemTime: time){
                guard let pixel = ws.output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
                let img = CIImage(cvPixelBuffer: pixel)
                let endImg = autoreleasepool {
                    ws.delegate?.videoPixelCallBack(source: img, bound: displayBound) ?? img
                }
                ws.render(renderImage: endImg, bound: displayBound, layer: displayer)
            }
        }
        self.link?.start()
    }
    
    deinit {
        link?.stop()
    }
    
    public init(){
        self.output = AVPlayerItemVideoOutput(outputSettings: [
            kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA
        ])
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        self.output = AVPlayerItemVideoOutput(outputSettings: [
            kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA
        ])
        super.init(coder: coder)
    }
}
