//
//  RouteViewController.swift
//  Data
//
//  Created by wenyang on 2022/10/31.
//

import UIKit
import butterfly

class RouteViewController: UIViewController {

    @RoutableProperty(route: Route(routeName: "routeEdit"))
    var controller:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.$controller.dequeue(param: ["key":"dadada"])
            guard let v = self.controller else { return }
            
            self.present(v, animated: true)
        }
        // Do any additional setup after loading the view.
    }
}

class RouteEditViewController: UIViewController {

    
    @RoutableProperty(route: Route(routeName: "route"))
    var controller:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{self.$controller.dequeue()
            guard let v = self.controller else { return }
            self.present(v, animated: true)
        })
        print(string)
        // Do any additional setup after loading the view.
    }
    @RouteParam(key: "key")
    var string:String?
}
