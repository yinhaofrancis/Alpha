//
//  butterflyDisplay.swift
//  butterfly
//
//  Created by hao yin on 2022/10/28.
//

import UIKit

public protocol butterflyDisplay{
    func show(route:String,animation:Bool,param:[String:Any]?)->Bool
    func replace(route:String,animation:Bool,param:[String:Any]?)->Bool
    func back(toRoute:String,animation:Bool)->Bool
    func back(animation:Bool)
    var currentRoute:String? { get }
    
    func display(url:URL,extra:[String:Any]?)->Bool
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
    
    public func display(url:URL,extra:[String:Any]?)->Bool {
        return false
    }
    
    private func load(route: String, param: [String : Any]?)->UIViewController?{
        guard let uivc = UIViewController.route(route: route, param: param) else { return nil }
        return uivc
    }
    
}
extension URL{
    public var param:[String:String]{
        var up = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let param:[String:String]? = up?.queryItems?.reduce(into: [:], { partialResult, item in
            guard item.value != nil else { return }
            partialResult[item.name] = item.value
        })
        guard let param  else { return [:] }
        return param
    }
}
