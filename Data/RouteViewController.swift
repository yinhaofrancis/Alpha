//
//  RouteViewController.swift
//  Data
//
//  Created by wenyang on 2022/10/31.
//

import UIKit
import butterfly
import TextDetect
class RouteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
protocol p{
    func make()
}
public class a:p{
    func make() {
        print("a:p")
    }
    
    
}
class RouteEditViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        Module.shared.addRoute(router: Router(proto: p.self, build: {
            a()
        }))
        Module.shared.dequeue(route: Route(proto: p.self))?.make()
        // Do any additional setup after loading the view.
    }
    @RouteParam(key: "key")
    var string:String?
    
    @RouteName
    var name:String?
}
