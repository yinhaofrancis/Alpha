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
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        jsContext.setObject(mm.self, forKeyedSubscript: "Mm" as NSString)
        jsContext.exceptionHandler = { a,b in
            print(b)
        }
        jsContext.evaluateScript("""
var a = new Mm("dd")
a.go()
""")
        self.lay.frame = CGRect(x: 0, y: 0, width: 100, height: 100);
        self.lay.backgroundColor = UIColor.red.cgColor;
        self.a = CABasicAnimation(keyPath: "transform.translation.x")
        a?.fromValue = 0
        a?.toValue = 100
        a?.duration = 3
        self.view.layer.addSublayer(self.lay)
        self.lay.add(self.a!, forKey: nil)
        self.amo.normalContent = [.text(UIFont.systemFont(ofSize: 14), .red, "abc"),.space(4),.imageUrl(URL(string: "https://img1.baidu.com/it/u=504762381,3391209024&fm=253&app=138&size=w43&n=0&f=JPEG&fmt=auto?sec=1659114000&t=5fd238c759ee939afc00a342cd18a70c")!, nil)]
        self.amo.highlightContent = [.text(UIFont.systemFont(ofSize: 14), .yellow, "abc"),.space(4),.imageUrl(URL(string: "https://img1.baidu.com/it/u=504762381,3391209024&fm=253&app=138&size=w43&n=0&f=JPEG&fmt=auto?sec=1659114000&t=5fd238c759ee939afc00a342cd18a70c")!, nil)]
    }

    var lay:CALayer = CALayer()
    
    var a:CABasicAnimation?
    
    @IBOutlet var amo:AMButton!
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lay.speed = 0.5
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


public class PageViewController:UIViewController,AMPageViewDelegate{
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
        self.pageView.pageDelegate = self
        self.pageView.reloadData()
        
    }
    public var vcs:[UIViewController] = []
    @IBOutlet public var pageView:AMPageContainerView!
}
