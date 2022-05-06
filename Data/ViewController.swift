//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
import TextDetect
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBAction func detect(_ sender: Any) {
        let c = UIImagePickerController()
        c.delegate = self
        c.sourceType = .camera
        self.showDetailViewController(c, sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        for _ in 0 ..< (arc4random() % 100){
//            DispatchQueue.global().async {
//                self.db.workflow { db in
//                    let json = JSONObject(json: ["ddd":"s"])
//                    try json.declare.create(db: db)
//                    try json.save(db: db)
//                }
//                try! self.db.query { db in
//                    let json:[JSONObject] = try JSONObject.select(db: db)
//                    print(json)
//                }
//            }
//        }
//    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img:UIImage = info[.originalImage] as? UIImage else { return }
        print(img)
        
        try! self.dt.detect(image: img.cgImage!) { strs in
            print(strs)
        }
        picker.dismiss(animated: true)
    }

    @DBWorkFlow(name:"mark")
    public var db:DataBaseWorkFlow
    
    var dt:TextDetect = TextDetect()

}


