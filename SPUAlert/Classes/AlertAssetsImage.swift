//
//  AlertAssetsImage.swift
//  SPUAlert
//
//  Created by wenyang on 2022/11/9.
//

import Foundation

public class AlertAssetsImage{
    public static func alertBackgroundImage(color:UIColor)->UIImage?{
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 9, height: 9), false, UIScreen.main.scale)
        defer{
            UIGraphicsEndImageContext()
        }
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 9, height: 9), cornerRadius: 3)
        color.setFill()
        path.fill()
        return UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
    }
}
