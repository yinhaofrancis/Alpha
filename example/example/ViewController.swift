//
//  ViewController.swift
//  example
//
//  Created by hao yin on 2022/11/3.
//

import UIKit
import SwiftUI
import SPUAlert
import butterfly
import Bit
import Dessert

var ap = 0;
@objc
class ViewController: UIViewController {

    
    @objc(navi)var navi:BINavigator?{
        didSet{
            
        }
    }
    @objc private(set) var mvn:(UIView & mm)?{
        didSet{
            self.mvn?.backgroundColor = UIColor.red
            self.mvn?.frame = CGRect(x: 0, y: 0, width: 100, height: 100);
            self.view .addSubview(self.mvn!)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ap == 0{
            ap += 1
            BIM().regModuleBaseClass(UIViewController.self, withName: "ex", implement: ViewController.self)
            BIM().regModuleBaseClass(UIView.self, withName: "mm", implement: VV.self)
            let vc = UIViewController.getInstanceByName("ex", params: nil)
            self .present(vc!, animated: true)
            
        }        // Do any additional setup after loading the view.
    }

    @butterfly
    var a:mm?
}

@objc(mm)
public protocol mm{
    var s:String? { get set }
}

public protocol mmm:UIView{
    var ss:String? { get set }
}
public class VV:UIView,mm,mmm{
    public var ss: String?
    
    public var s: String?
}
