//
//  ModelView.swift
//  Ammo
//
//  Created by hao yin on 2022/7/20.
//

import UIKit

public protocol ViewModel{
    var viewModel:Dictionary<String,String> { get set }
}
private struct _innerAsKv{
    public static var viewModel:String = "viewModel"
    public static var adaptorModelAdaptor:String = "adaptorModelAdaptor"
}

public enum ValueType{
    case null
    case Integer
    case Double
    case Size
    case Point
    case Rect
    case Color
    case Url
    case String
    case transform
    case transform3d
    case cgPath
}

extension UIView: ViewModel{
    public var viewModel: Dictionary<String, String>{
        get{
            guard let dic = objc_getAssociatedObject(self, &_innerAsKv.viewModel) as? Dictionary<String, String> else {
                return [:]
            }
            return dic
        }
        set{
            objc_setAssociatedObject(self, &_innerAsKv.viewModel, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    public var adaptor:ModelAdaptor? {
        get{
            objc_getAssociatedObject(self,&_innerAsKv.adaptorModelAdaptor) as? ModelAdaptor
        }
        set{
            objc_setAssociatedObject(self, &_innerAsKv.adaptorModelAdaptor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
extension UILabel{
    
}
public protocol ModelAdaptor{
    func loadViewModel(viewModel:Dictionary<String, String>)
}
public class ViewModelAdaptor<View:UIView>{
    public var view:View
    public func loadViewModel(view: View, viewModel: Dictionary<String, String>) {
        self.view = view
    }
    public init(view:View) {
        self.view = view
    }
}

