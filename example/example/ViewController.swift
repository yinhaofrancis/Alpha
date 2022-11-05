//
//  ViewController.swift
//  example
//
//  Created by hao yin on 2022/11/3.
//

import UIKit
import SwiftUI


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 15.0, *) {
            DispatchQueue.main.async {
                self.present(UIHostingController(rootView: Sender()), animated: true)
            }
        } else {
            // Fallback on earlier versions
        }
    }


}

