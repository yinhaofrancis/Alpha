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

@objc
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()     // Do any additional setup after loading the view.
        self.view.addSubview(self.a!)
        self.a?.backgroundColor = .green
        self.a?.frame = CGRect(x: 20, y: 40, width: 100, height: 100)
    }

    @ParamButterfly(name: "nnn")
    var nnn:String?
    
    @ParamButterfly(name: "aa")
    var aa:Double?
    
    @PathButterfly(name: "mmm")
    var a:UIView?

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

public class VVV:UILabel,mm,mmm{
    public var ss: String?
    
    public var s: String?
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        self.text = "dasd"
    }
}
