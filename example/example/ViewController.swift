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
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        butterFlyViewManager.register(route: Router<UIView>(proto: mm.self, memory: .singlton,cls: VV.self))
        butterFlyViewManager.register(route: Router<UIView>(proto: mmm.self, memory: .singlton,cls: VV.self))
        let a = try? butterFlyViewManager.dequeue(proto: mm.self)
        
        let b = try? butterFlyViewManager.dequeue(proto: mmm.self)
        
        print(a,b)
    }


}

public protocol mm:UIView{
    var s:String? { get set }
}
public protocol mmm:UIView{
    var ss:String? { get set }
}
public class VV:UIView,mm,mmm{
    public var ss: String?
    
    public var s: String?
}
