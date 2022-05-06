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
        print(UserDefaults.standard.float(forKey: "slider_preference"))
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

    @DBWorkFlow(name:"mark")
    public var db:DataBaseWorkFlow

}


