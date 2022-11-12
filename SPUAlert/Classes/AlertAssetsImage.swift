//
//  AlertAssetsImage.swift
//  SPUAlert
//
//  Created by wenyang on 2022/11/9.
//

import Foundation

public class AlertAssetsImage{
    public static func alertBackgroundImage(color:UIColor,lineColor:UIColor,size:CGFloat,radius:CGFloat,buttomHeight:CGFloat)->UIImage?{
        let height = buttomHeight + radius + 20
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: height), false, UIScreen.main.scale)
        defer{
            UIGraphicsEndImageContext()
        }
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: height), cornerRadius: radius)
        color.setFill()
        path.fill()
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 0, y: height - buttomHeight))
        line.addLine(to: CGPoint(x: size, y: height - buttomHeight))
        line.move(to: CGPoint(x: size / 2, y: height - 10))
        line.addLine(to: CGPoint(x: size / 2, y: height - buttomHeight + 10))
        line.lineWidth = 1;
        lineColor.setStroke()
        line.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets(top: radius + 10, left: 0, bottom:buttomHeight + 10 , right: 0),resizingMode: .stretch)
    }
}
