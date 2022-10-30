//
//  butterflyDisplay.swift
//  butterfly
//
//  Created by hao yin on 2022/10/28.
//

import UIKit
public enum RouteAction:String{
    case show = "show"
    case replace = "replace"
    case backTo = "backTo"
    case back = "back"
}
public protocol butterflyDisplay{
    func show(route:String,animation:Bool,param:[String:Any]?)->Bool
    func replace(route:String,animation:Bool,param:[String:Any]?)->Bool
    func back(toRoute:String,animation:Bool)->Bool
    func back(animation:Bool)
    var currentRoute:String? { get }
}

public class butterFlyNavigationController:UINavigationController,butterflyDisplay{
    public func show(route: String,animation:Bool, param: [String : Any]?)->Bool {
        guard let curr = self.load(route: route, param: param) else { return false }
        self.pushViewController(curr, animated: animation)
        return true
    }
    
    public func replace(route: String,animation:Bool, param: [String : Any]?)->Bool {
        guard let vc = self.load(route: route, param: param) else { return false }
        var array = self.viewControllers
        array.removeLast()
        array.append(vc)
        self.setViewControllers(array, animated: animation)
        return true
    }
    
    public func back(toRoute: String,animation:Bool)->Bool {
        guard let vc = self.viewControllers.reversed().first(where:{ $0.route != nil && $0.route! == toRoute }) else { return false}
        self.popToViewController(vc, animated: animation)
        return true
    }
    
    public func back(animation:Bool) {
        self.popViewController(animated: true)
    }
    
    public var currentRoute: String?

    private func load(route: String, param: [String : Any]?)->UIViewController?{
        guard let uivc = UIViewController.route(route: Route(routeName: route,param: param)) else { return nil }
        return uivc
    }
    private func merge(param:[String:String],extra:[String:Any])->[String:Any]{
        return extra.merging(param) { i, j in
            return j
        }
    }
}
extension URL{
    public var param:[String:String]{
        let up = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let param:[String:String]? = up?.queryItems?.reduce(into: [:], { partialResult, item in
            guard item.value != nil else { return }
            partialResult[item.name] = item.value
        })
        guard let param  else { return [:] }
        return param
    }
    public var plainPath:String{
        if #available(iOS 16.0, *) {
            return self.path()
        } else {
            return self.path
        }
    }
    public var plainFragment:String?{
        if #available(iOS 16.0, *) {
            return self.fragment()
        } else {
            return self.fragment
        }
    }
    public var plainRouteAction:RouteAction{
        RouteAction(rawValue: self.plainFragment ?? "show") ?? .show
    }
}

public class butterflyNavigationBar:UINavigationBar{
    
}
