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
extension Icon{
    public static var make = Icon(text: "\u{e687}", color: UIColor.yellow, size: 43)
}
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
   
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var iamgev: UIImageView!
    let font:IconFont = try! IconFont()
    let renderctx = try! RenderContext(size: CGSize(width: 320, height: 480), scale: 3,reverse: true)
    override func viewDidLoad() {
        super.viewDidLoad()
        var j:CGFloat = 0
        let a = NSAttributedString(string: "ada", attributes: [
            .font:UIFont.systemFont(ofSize: 12),
            .foregroundColor:UIColor.white
        ]) as CFAttributedString
        let v = RenderTextView(frame: CGRect(x: 0, y: 0, width: 150, height: 150), context: self.renderctx)
        let b = RenderImageView(image: UIImage(named: "i")!.cgImage!, position: CGPoint(x: 0, y: 0), context: self.renderctx)
        v.attributedString = a;
        v.clip = true
        v.content = ImageFillContent(image: UIImage(named: "i")?.cgImage)
        v.shadowColor = UIColor.red.cgColor
        v.shadowRadius = 6
        v.radius = 5
        v.addSubView(view: b)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { t in
            j = CGFloat(arc4random() % 30)
            v.frame = CGRect(x:  j, y: j, width: v.frame.width, height: v.frame.height)
            v.render(ctx: self.renderctx)
            self.iamgev.image = UIImage(cgImage: self.renderctx.image! ,scale: self.renderctx.scale,orientation: .up)
            self.renderctx.clean()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
     
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


public class PageViewController:UIViewController{
    public var numberOfPage: Int{
        return 10
    }
    
    public func viewAtIndex(index: Int) -> UIView {
        let l = UILabel()
        l.textColor = .white
        l.backgroundColor = UIColor(red: CGFloat(arc4random() % 100) / 99.0 , green: CGFloat(arc4random() % 100) / 99.0 , blue: CGFloat(arc4random() % 100) / 99.0 , alpha: 1)
        l.textAlignment = .center
        l.text = "\(index) page"
        return l
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        for i in 0 ..< 1{
            guard let vc = self.storyboard?.instantiateViewController(identifier: "ccc") as? UICollectionViewController else { break }
      
            self.vcs.append(vc)
        }
    }
    public var vcs:[UIViewController] = []

}
