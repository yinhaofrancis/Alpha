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
        
        try! self.dt.detectQR(image: img.cgImage!, callback: { o in
            let a = placeDecode.decode(o: o)
            let n = a.map { i in
                placeDecode.decodeName(code: i)
            }.compactMap({$0})
            print(n)
        })
        
        
        
        picker.dismiss(animated: true)
        
    }

    @DBWorkFlow(name:"mark")
    public var db:DataBaseWorkFlow
    
    var dt:TextDetect = TextDetect()

}
public class placeDecode{
    public static func decode(o:[String])->[String]{
        let a:[[String:String]] = o.map { i in
            URLComponents(string: i)?.queryItems
        }.compactMap({$0}).map { i in
            let a:[String:String] = i.reduce(into: [:]) { partialResult, o in
                guard let v = o.value else { return }
                partialResult[o.name] = v
            }
            return a
        }
        return a.map { i in
            i["query"]
        }.compactMap({$0})
    }
    public static func decodeName(code:String)->String?{
        code.components(separatedBy: "communityName=").last
    }
}

