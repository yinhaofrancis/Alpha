//
//  ViewController.swift
//  example
//
//  Created by hao yin on 2022/11/3.
//

import UIKit
import SwiftUI
import SPUAlert

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 15.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.present(AlertViewController(title: "title", content: "content", titles: ["a","b"]), animated: true)
            }
        } else {
            // Fallback on earlier versions
        }
    }


}


