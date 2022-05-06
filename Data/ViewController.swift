//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for _ in 0 ..< (arc4random() % 100){
            DispatchQueue.global().async {
                self.db.workflow { db in
                    let json = JSONObject(json: ["ddd":"s"])
                    try json.declare.create(db: db)
                    try json.save(db: db)
                }
                try! self.db.query { db in
                    let json:[JSONObject] = try JSONObject.select(db: db)
                    print(json)
                }
            }
        }
    }

    @DBWorkFlow(name:"mark")
    public var db:DataBaseWorkFlow

}


