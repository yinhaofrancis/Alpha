//
//  RouteViewController.swift
//  Data
//
//  Created by wenyang on 2022/10/31.
//

import UIKit
import butterfly

class RouteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class RouteEditViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.string)
        // Do any additional setup after loading the view.
    }
    @RouteParam(key: "key")
    var string:String?
}
