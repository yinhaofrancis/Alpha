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

        self.kol?.call(event: .KLO1)?.call(param: nil,ret: { r in
            print(r)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedModuleBucket.sharedConfiguration {
            KOL.self
        }
        SharedModuleBucket.resetConfiguration()
    }


    @ModuleProperty(name: "KOL")
    var kol:KOL?

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

