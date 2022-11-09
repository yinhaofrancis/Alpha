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
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.present(AlertViewController(title:"dasdasd",content: "asdjadfjas fkajsdhfasjdfha sdkf askdf `", cancel: "cancel", primary: "OK", callback: { i in
            
        }), animated: true)
    }


}


