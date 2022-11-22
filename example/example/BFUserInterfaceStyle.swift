//
//  BFUserInterfaceStyle.swift
//  example
//
//  Created by hao yin on 2022/11/22.
//

import UIKit


extension UIImage{
    public static func image(dynamicProvider:(UIUserInterfaceStyle)->UIImage?)->UIImage{
        let assert = UIImageAsset()
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        light.performAsCurrent {
            guard let image = dynamicProvider(.light) else { return }
            assert.register(image, with: UITraitCollection(userInterfaceStyle: .light))
        }
        dark.performAsCurrent {
            guard let image = dynamicProvider(.dark) else { return }
            assert.register(image, with: UITraitCollection(userInterfaceStyle: .dark))
        }
        return assert.image(with: UITraitCollection(traitsFrom: [light,dark]))
    }
    public static func image(dynamicProvider:(UIUserInterfaceStyle)->CGImage?)->UIImage{
        let assert = UIImageAsset()
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        light.performAsCurrent {
            guard let image = dynamicProvider(.light) else { return }
            assert.register(UIImage(cgImage: image), with: UITraitCollection(userInterfaceStyle: .light))
        }
        dark.performAsCurrent {
            guard let image = dynamicProvider(.dark) else { return }
            assert.register(UIImage(cgImage: image), with: UITraitCollection(userInterfaceStyle: .dark))
        }
        return assert.image(with: UITraitCollection(traitsFrom: [light,dark]))
    }
}

extension UIColor{
    public convenience init(lightColor:UIColor,darkColor:UIColor){
        self.init { i in
            if(i.userInterfaceStyle == .dark){
                return darkColor
            }else{
                return lightColor
            }
        }
    }
    public convenience init(color:String){
        let s = color.components(separatedBy: "_")
        var l:UInt32 = UInt32(Scanner(string: s.first ?? "").scanUInt64(representation: .hexadecimal) ?? 0)
        if(l >> 24 == 0){
            l = l | 0xff000000
        }
        var d:UInt32 = UInt32(Scanner(string: s.last ?? "").scanUInt64(representation: .hexadecimal) ?? 0)
        
        if(d >> 24 == 0){
            d = d | 0xff000000
        }
        self.init(lightColor: UIColor(argb: l), darkColor: UIColor(argb:d))
    }
    public convenience init(color64:String){
        let s = color64.components(separatedBy: "_")
        var l:UInt64 = Scanner(string: s.first ?? "").scanUInt64(representation: .hexadecimal) ?? 0
        if(l >> 48 == 0){
            l = l | 0xffff000000000000
        }
        var d:UInt64 = Scanner(string: s.last ?? "").scanUInt64(representation: .hexadecimal) ?? 0
        if(d >> 48 == 0){
            d = d | 0xffff000000000000
        }
        self.init(lightColor: UIColor(argb: l), darkColor: UIColor(argb:d))
    }
    public convenience init(argb:UInt32){
        let a = CGFloat((argb & 0xFF000000) >> 24)  / 255.0
        
        let r = CGFloat((argb & 0x00FF0000) >> 16) / 255.0
        
        let g = CGFloat((argb & 0x0000FF00) >> 8) / 255.0
        
        let b = CGFloat(argb & 0x000000FF)  / 255.0
        
        self.init(displayP3Red: r, green: g, blue: b, alpha: a)
    }
    public convenience init(argb:UInt64){
        let a = CGFloat((argb & 0xFFFF000000000000) >> 48)  / (1.0 * CGFloat(0xffff))
        
        let r = CGFloat((argb & 0x0000FFFF00000000) >> 32) / (1.0 * CGFloat(0xffff))
        
        let g = CGFloat((argb & 0x00000000FFFF0000) >> 16) / (1.0 * CGFloat(0xffff))
        
        let b = CGFloat(argb &  0x000000000000FFFF)  / (1.0 * CGFloat(0xffff))
        
        self.init(displayP3Red: r, green: g, blue: b, alpha: a)
    }
    public convenience init(rgb:UInt64){
        let r = CGFloat((rgb & 0x0000FFFF00000000) >> 32) / (1.0 * CGFloat(0xffff))
        
        let g = CGFloat((rgb & 0x00000000FFFF0000) >> 16) / (1.0 * CGFloat(0xffff))
        
        let b = CGFloat(rgb &  0x000000000000FFFF)  / (1.0 * CGFloat(0xffff))
        
        self.init(displayP3Red: r, green: g, blue: b, alpha: 1)
    }
    public convenience init(rgb:UInt32){
        let r = CGFloat((rgb & 0x00FF0000) >> 16)  / 255.0
        
        let g = CGFloat((rgb & 0x0000FF00) >> 8)  / 255.0
        
        let b = CGFloat((rgb & 0x000000FF))  / 255.0
        
        self.init(displayP3Red: r, green: g, blue: b, alpha: 1)
    }
}
