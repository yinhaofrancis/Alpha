//
//  Pretty.swift
//  Ammo
//
//  Created by hao yin on 2022/6/27.
//

import Foundation
import UIKit

public class PrettyJSON{
    public var stack:[String] = []
    private var last:String{
        self.stack.last ?? ""
    }
    public var attribute:NSAttributedString{
        var current:String = ""
        let result = NSMutableAttributedString()
        for i in code{
            if self.last == "\""{
                if(i == "\""){
                    stack.removeLast(1)
                    current += "\""
                    result.append(self.keyStrStopWord(str: current))
                    current = ""
                }else{
                    current.append(i)
                }
                
            }else{
                if i == "{"{
                    stack.append(String(i))
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                }else if i == "}"{
                    stack.removeLast(1)
                    result.append(self.keyStopWord(str: current))
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                    current = ""
                }else if i == "["{
                    stack.append(String(i))
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                }else if i == "]"{
                    stack.removeLast(1)
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                    current = ""
                }else if i == ","{
                    result.append(self.keyStopWord(str: current))
                    result.append(self.keyWord(str: ",\n"))
                    result.append(self.space(n: stack.count))
                    current = ""
                }else if i == "\""{
                    stack.append("\"")
                    current += "\""
                }else if i == ":"{
                    result.append(self.keyStartWord(str: current))
                    result.append(self.keyWord(str: ":"))
                    current = ""
                }else{
                    current += String(i)
                }
            }
            
        }
        return result
    }
    private func space(n:Int)->NSAttributedString{
        if(n == 0){
            return NSAttributedString()
        }else{
            return NSAttributedString(string: (0 ..< n).reduce(into: "") { partialResult, _ in
                partialResult += "\t"
            }, attributes: [
                .font:UIFont.systemFont(ofSize: 15)
            ])
        }
    }
    private func keyWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemBlue
        ])
    }
    private func keyStartWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemOrange
        ])
    }
    private func keyStopWord(str:String)->NSAttributedString{
        if str.starts(with: "\""){
            return self.keyStrStopWord(str: str)
        }else{
            return self.keyValStopWord(str: str)
        }
    }
    private func keyStrStopWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemRed
        ])
    }
    private func keyValStopWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemYellow
        ])
    }
    
    public var code:String
    public init(code:Data) throws{
        try JSONSerialization.jsonObject(with: code)
        guard let str = String(data: code, encoding: .utf8) else { throw NSError(domain: "json error", code: 0)}
        self.code = str
    }
}
extension UIImageView{
    public func am_imageUrl(url:URL,placeholdImage:UIImage? = nil){
        self.image = placeholdImage
        StaticImageDownloader.shared.downloadImage(url: url) {[weak self] img in
            guard let image = img else { return }
            let uiimg = UIImage(cgImage: image)
            self?.image = uiimg
        }
    }
}
