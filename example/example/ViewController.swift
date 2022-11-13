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
        
        ButterFlyRouter.shared.register(route: Router(proto: mm.self, memory: .singlton,cls: VV.self))
        ButterFlyRouter.shared.register(route: PathRouter(name:"/a/b/c",cls: VV.self))
        ButterFlyRouter.shared.register(route: Router(proto: mmm.self, memory: .singlton,cls: VV.self))
        
        print(a)
    }
    @butterfly
    var a:mm?
}

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
