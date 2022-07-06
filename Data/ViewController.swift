//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
import TextDetect
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layout()
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
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    @IBAction public func load(){
        let url = URL(string: "https://qrimg.jd.com/https%3A%2F%2Fitem.m.jd.com%2Fproduct%2F10050608187053.html%3Fpc_source%3Dpc_productDetail_10050608187053-118-1-4-2.png?ltype=0")!
        self.images.removeAll()
//        ImageDownloader.shared.downloader.delete(url: url)
        let n = 1
        for i in 0 ..< n{
            
            DispatchQueue.global().async {
                StaticImageDownloader.shared.downloadImage(url:url) {[weak self] img in
                    guard let im = img else { return }
                    self?.images.append(UIImage(cgImage: im))
                    guard let ws = self else { return }
               
                    if(ws.images.count > n - 1){
                        DispatchQueue.main.async {
                            ws.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
