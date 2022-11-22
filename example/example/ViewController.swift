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
class ViewController: UIViewController {

    lazy var bi = {
        return BIProxy(object: self)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ButterFlyRouter.shared.register(route: Router(proto: mm.self, cls: VV.self))
        ButterFlyRouter.shared.register(route: PathRouter(name:"/a/b/c",cls: VV.self))
        ButterFlyRouter.shared.register(route: Router(proto: mmm.self, cls: VV.self))
        
//        self.load(vc: self, frame: CGRect(x: 0, y: 0, width: 300, height: 300), count: 5)
        let a = Stack(axis: .vertical,distribution: .fillEqually) {
            Label(text: "kkkk", font: .systemFont(ofSize: 12), textColor: UIColor.red)
            Label(text: "kkkk", font: .systemFont(ofSize: 12), textColor: UIColor.red)
            Label(text: "kkkk", font: .systemFont(ofSize: 12), textColor: UIColor.red)
            Label(text: "kkkk", font: .systemFont(ofSize: 12), textColor: UIColor.red)
            Label(text: "kkkk", font: .systemFont(ofSize: 12), textColor: UIColor.red)
        }
        self.view.backgroundColor = UIColor(color64: "0x0000ffff0000_0x0000ff00ff00")
        DessertStorage
    }

    @butterfly
    var a:mm?
    
    @IBAction func change(_ sender: UISwitch) {
        UIApplication.shared.update(style: sender.isOn ? .dark : .light)
        print(self.traitCollection.userInterfaceStyle)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    func load(vc:UIViewController,frame:CGRect,count:Int){
        let a = UIViewController()
        vc.addChild(a);
        vc.view.addSubview(a.view)
        a.view.backgroundColor = UIColor(named: "test")
        a.view.frame = frame
        if(count == 0){
            return
        }else{
            self.load(vc: a, frame: frame.insetBy(dx: 10, dy: 10), count: count - 1)
        }
    }
    
}
extension UIViewController{
    func update(style:UIUserInterfaceStyle){
        self.overrideUserInterfaceStyle =  style
        self.children.forEach { v in
            v.overrideUserInterfaceStyle = style
        }
        var vc = self.presentedViewController
        while(vc != nil){
            vc?.overrideUserInterfaceStyle = style
            vc = vc?.presentedViewController
        }
    }
}
extension UIApplication{
    public func update(style:UIUserInterfaceStyle){
        self.openSessions.compactMap { i in
            i.scene as? UIWindowScene
        }.flatMap { i in
            i.windows
        }.forEach { i in
            i.rootViewController?.update(style: style)
        }
    }
}
class NaviViewController:UINavigationController{
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.update(style: .light)
        }
    }
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
