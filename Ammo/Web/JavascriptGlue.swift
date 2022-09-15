//
//  JavascriptGlue.swift
//  Ammo
//
//  Created by hao yin on 2022/8/23.
//

import Foundation
import JavaScriptCore
import UIKit

public class JSManager{
    public var context:JSContext = JSContext()
    
    public static var shared:JSManager = JSManager()
}

public protocol JavaScriptGlue:JSExport{
    var content:[String:Any]? { get set }
}

var v:String = "view_key"
extension UIView{
    public var key:String? {
        get{
            return objc_getAssociatedObject(self, &v) as? String
        }
        set{
            objc_setAssociatedObject(self, &v, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
public class JSContentView:UIView,JavaScriptGlue{
    public var content: [String:Any]?{
        didSet{
            self.namedValue.forEach { i in
                i.value.content = self.content?[i.key] as? [String:Any]
            }
        }
    }
    public var namedValue:[String:(UIView & JavaScriptGlue)] = [:]
    public override func addSubview(_ view: UIView) {
        if let name = view.key {
            self.namedValue[name] = view as? (UIView & JavaScriptGlue)
        }
        super.addSubview(view)
        
    }
    public override func willRemoveSubview(_ subview: UIView) {
        if let name = subview.key {
            self.namedValue .removeValue(forKey: name)
        }
        super.willRemoveSubview(subview)
    }
}
public class JSStackContentView:UIStackView,JavaScriptGlue{
    public var content: [String:Any]?{
        didSet{
            self.namedValue.forEach { i in
                i.value.content = self.content?[i.key] as? [String:Any]
            }
        }
    }
    public var namedValue:[String:(UIView & JavaScriptGlue)] = [:]
    public override func addSubview(_ view: UIView) {
        if let name = view.key {
            self.namedValue[name] = view as? (UIView & JavaScriptGlue)
        }
        super.addSubview(view)
        
    }
    public override func willRemoveSubview(_ subview: UIView) {
        if let name = subview.key {
            self.namedValue .removeValue(forKey: name)
        }
        super.willRemoveSubview(subview)
    }
}

public class JViewController:UIViewController,JavaScriptGlue{
    
    public var content: [String:Any]?{
        didSet{
            if let name = self.contentView.key{
                self.contentView.content = self.content?[name] as? [String:Any]
            }else{
                self.contentView.content = self.content
            }
            
        }
    }
    public var contentView:(JavaScriptGlue & UIView)
    
    public init(){
        self.contentView = JSContentView()
        super.init(nibName: nil, bundle: nil)
    }
    public override func loadView() {
        self.view = self.contentView
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
