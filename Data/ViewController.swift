//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
   
    let ctx = try! RenderContext(size: CGSize(width: 100, height: 100), scale: 3,reverse: true);
    @IBOutlet weak var image:UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let a = NSMutableAttributedString()
        a.append(NSAttributedString(string: "dsds", attributes:
                                        [.foregroundColor:UIColor.red,
                                         .font:UIFont.systemFont(ofSize: 10)]))
        let aa = KateRun(font: UIFont.systemFont(ofSize: 20)).attribute
        a.append(aa)
        a.append(NSAttributedString(string: "dsds", attributes:
                                        [.foregroundColor:UIColor.red,
                                         .font:UIFont.systemFont(ofSize: 10)]))
        ctx.drawString(string: a as CFAttributedString, constaint: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let i = UIImage(cgImage: ctx.image!,scale: 3,orientation: .up)
        
        self.image?.image = i;
    }
    
}


