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
        Task {
            print("dadasa")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func k() async{
        
    }


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

