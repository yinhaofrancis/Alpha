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
        let url = URL(string: "https://www.haose.xxx/contents/ymqeeqlopose/theme/logo.png")!
        self.images.removeAll()
        ImageDownloader.shared.downloader.delete(url: url)
        for i in 0 ..< 100{
            
            DispatchQueue.global().async {
                ImageDownloader.shared.downloadImage(url:url) {[weak self] img in
                    guard let im = img else { return }
                    self?.images.append(UIImage(cgImage: im))
                    guard let ws = self else { return }
               
                    if(ws.images.count > 99){
                        DispatchQueue.main.async {
                            ws.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
