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
    override func viewDidLoad() {
        super.viewDidLoad()
        let rg = RenderGradient(colors: [UIColor.red.cgColor,UIColor.blue.cgColor], location: [0,1], relatePoint1: .zero, relatePoint2: CGPoint(x:120, y: 0))
        let cgimg = try! IconFont.shared.charMaskImage(background: rg, icon: Icon.make, clipFillMode: .evenOdd)
        self.iamgev.image = UIImage(cgImage: cgimg ,scale: UIScreen.main.scale,orientation: .up)
        self.text.attributedText = Icon.make.string
        
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
