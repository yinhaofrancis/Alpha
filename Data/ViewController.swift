//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
import TextDetect
import WebKit
import simd
import MetalKit
extension Icon{
    public static var make = Icon(text: "\u{e687}", color: UIColor.yellow, size: 12)
}
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
   
    
    @IBOutlet weak var text: UILabel!
    var iamgev: CAMetalLayer!
    let com = try! CokeComputer()
    let font:IconFont = try! IconFont()
    lazy var b = {
        RenderURLImageView(url: URL(string: "https://news-bos.cdn.bcebos.com/mvideo/log-news.png")!, frame: CGRect(x: 10, y: 10, width: 80, height: 30), context: self.renderctx)
    }()
    let renderctx = try! RenderContext(size: CGSize(width: 320, height: 480), scale: 3,reverse: true)
    var float:CGFloat = 0
    var step:CGFloat = 1
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        self.iamgev =  CAMetalLayer()
        self.iamgev.contentsScale = UIScreen.main.scale;
        self.iamgev.frame = CGRect(x: 0, y: 100, width: 300, height: 300)
        self.iamgev.framebufferOnly = false
        self.iamgev.device = com.device
        self.iamgev.pixelFormat = CokeConfig.metalColorFormat;
        self.view.layer .addSublayer(self.iamgev)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] t in
            guard let t = self.iamgev.nextDrawable() else { return }
            run(drawable: t)
            
        }
        self.iamgev.device = com.device
    }
    func run(drawable:CAMetalDrawable){
        let text = drawable.texture

//        guard let text = com.configuration.createTexture(width: 300, height: 300) else { return }
//
//        let buffer = try! com.configuration.begin()
//        let databuffer = com.configuration.createBuffer(data: [SIMD2<Float>(x: 10, y: 10),SIMD2<Float>(x: 50, y: 80)]);
//        try! com.compute(name: "linearBezier", buffer: buffer, countOfGrid: 300, buffers: [databuffer!], textures: [text])
//        com.configuration.commit(buffer: buffer)
//        let ciimage = com.configuration.createCIImage(texture: text)!
//
//        self.iamgev.image = UIImage(ciImage: ciimage,scale: UIScreen.main.scale, orientation: .up)
        let c = try! CokeRender2d(texture: text)
        try! c.begin()
        
        try! c.drawLine(point1: .zero, point2: CGPoint(x: 200, y: 200))
        
        try! c.drawQuadraticBezier(point1: .zero, point2: CGPoint(x: 150, y: float), point3: CGPoint(x: 300, y: 0))
        
        
        try! c.drawCubicBezier(point1: .zero, point2: CGPoint(x: 100, y: float), point3: CGPoint(x: 200, y: -float), point4: CGPoint(x: 300, y: 300))
        float += step
        if(float > 100 || float < 0){
            step = -step;
        }
        c.present(drawble: drawable)
        c.commit()
        
    }
}


class CollectionCell:UICollectionViewCell{
    @IBOutlet weak var imageView:UIImageView!
}

class collectionViewController:UICollectionViewController{
    
    
    public var images:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.load()
        self.collectionView.contentInsetAdjustmentBehavior = .never
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    var t:DispatchSourceTimer?
    @IBAction public func load(){
        let url = URL(string: "https://qrimg.jd.com/https%3A%2F%2Fitem.m.jd.com%2Fproduct%2F10050608187053.html%3Fpc_source%3Dpc_productDetail_10050608187053-118-1-4-2.png?ltype=0")!
        self.images.removeAll()
//        ImageDownloader.shared.downloader.delete(url: url)
        
        for i in 0 ..< 50{
            StaticImageDownloader.shared.downloadImage(url:url) {[weak self] img in
                guard let im = img else { return }
                self?.images.append(UIImage(cgImage: im))
                guard let ws = self else { return }
                ws.collectionView.reloadData()
            }
        }
    }
    deinit{
        self.t?.cancel()
    }
}


public class PageViewController:UIViewController,AMPageViewDelegate,UITableViewDelegate,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aaa", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    var sc:[Int:UIScrollView] = [:]
    public func currentScrollAtIndex(index: Int) -> UIScrollView {
        sc[index]!
    }
    
    public func childViewAtIndex(index: Int) -> UIView {
        let s = UITableView()
        s.register(UITableViewCell.self, forCellReuseIdentifier: "aaa")
        s.backgroundColor = UIColor(red: CGFloat(arc4random() % 9) / 10.0, green: 1, blue: 1, alpha: 1)
        s.delegate = self
        s.dataSource = self
        sc[index] = s
        return s
    }
    
    public func numberOfChild() -> Int {
        return 10
    }
    public func topView() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.red
        return v
    }
    
    public func topViewHeight() -> Int {
        return 128
    }
    
    public func topViewMinHeight() -> Int {
        return 44
    }
    
    
    @IBOutlet weak var page: AMPageView!
   
    
   
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.page.reload()
    }
}
class vViewController: UIViewController,UIScrollViewDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 3000)
        self.scrollView.delegate = self
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            topConstraint.constant = -scrollView.contentOffset.y
        }else{
            topConstraint.constant = 0
        }
    }
}
