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
    case dismiss = "dismiss"
    case present = "present"
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
        self.fragment
    }
    public var plainRouteAction:RouteAction{
        RouteAction(rawValue: self.plainFragment ?? "show") ?? .show
    }
    public var pathElement:[String]{
        return self.plainPath.components(separatedBy: CharacterSet(["/"])).filter { i in
            i.count > 0
        }
    }
    public func merge(extra:[String:Any]?)->[String:Any]?{
        return extra?.merging(param) { i, j in
            return j
        }
    }
}
public protocol butterflyDisplay:AnyObject{
    func show(route: Route<UIViewController>,animation:Bool)->UIViewController?
    func replace(route: Route<UIViewController>,animation:Bool)->UIViewController?
    func back(toRoute:String,animation:Bool)->UIViewController?
    func model(route: Route<UIViewController>,animation:Bool)->UIViewController?
    func back(animation:Bool)
    var currentRoute:String? { get }
    func openUrl(route:String,
                 param:[String:Any]?,
                 action:RouteAction,
                 animation:Bool)->UIViewController?
}
extension UINavigationController:butterflyDisplay{
    public func openUrl(route: String, param: [String : Any]?, action: RouteAction, animation: Bool) -> UIViewController? {
        switch(action){
            
        case .show:
            return self.show(route: Route(routeName: route,param: param), animation: animation)
        case .replace:
            return self.replace(route: Route(routeName: route,param: param), animation: animation)
        case .backTo:
            return self.back(toRoute: route, animation: animation)
        case .back:
            self.back(animation: animation)
            return nil
        case .dismiss:
            self.dismiss(animated: animation)
            return nil
        case .present:
            return self.model(route: Route(routeName: route,param: param), animation: animation)
            
        }
    }
    
    public func show(route: Route<UIViewController>,animation:Bool)->UIViewController? {
        if(route.routeName == currentRoute){
            return self
        }
        guard let curr = self.load(route: route) else { return nil }
        self.pushViewController(curr, animated: animation)
        return curr
    }
    public func model(route: Route<UIViewController>,animation:Bool)->UIViewController? {
        if(route.routeName == currentRoute){
            return self
        }
        guard let curr = self.load(route: route) else { return nil }
        self.present(curr, animated: animation)
        return curr
    }
    public func replace(route: Route<UIViewController>,animation:Bool)->UIViewController? {
        if(route.routeName == currentRoute){
            return self
        }
        guard let vc = self.load(route: route) else { return nil }
        var array = self.viewControllers
        array.removeLast()
        array.append(vc)
        self.setViewControllers(array, animated: animation)
        return vc
    }
    
    public func back(toRoute: String,animation:Bool)->UIViewController? {
        if(toRoute == currentRoute){
            return self
        }
        guard let vc = self.viewControllers.reversed().first(where:{ $0.route != nil && $0.route! == toRoute }) else { return nil }
        self.popToViewController(vc, animated: animation)
        return vc
    }
    
    public func back(animation:Bool) {
        self.popViewController(animated: true)
    }
    
    public var currentRoute: String?{
        self.topViewController?.route
    }

    private func load(route: Route<UIViewController>)->UIViewController?{
        guard let uivc = UIViewController.route(route: route) else { return nil }
        return uivc
    }
}



public class Controller{
    public var window:UIWindow
    public init(window: UIWindow) {
        self.window = window
    }
    private var routeManager:butterfly = butterfly.shared(type: UIViewController.self)
    public func openUrl(url:URL,
                        extra:[String:Any]? = nil ,
                        animation:Bool = true)->Bool {
        let param = url.merge(extra: extra)
        let routes = url.pathElement
        let action = url.plainRouteAction
        return self.openUrl(routes: routes,param: param,action: action,animation: animation)
    }
    
    func openUrl(routes:[String],
                 param:[String:Any]? = nil,
                 action:RouteAction = .show,
                 animation:Bool = true)->Bool{
        var display:(UIViewController & butterflyDisplay)?
        for i in routes{
            if(i == "~"){
                display = nil
                continue
            }
            if let a = routeManager.singlton(route: i){
                display = a as? (UIViewController & butterflyDisplay)
                if(self.window.rootViewController == nil){
                    self.window.rootViewController = a
                }
            }else{
                if(display == nil){
                    guard let vc = routeManager.dequeue(route: Route(routeName: i,param: param)) else { return false }
                    if(self.window.rootViewController == nil){
                        self.window.rootViewController = vc
                        display = vc as? (UIViewController & butterflyDisplay)
                    }else{
                        self.window.rootViewController?.present(vc, animated: i == routes.last ? true : false)
                        display = vc as? (UIViewController & butterflyDisplay)
                    }
                }else{
                
                    let newdisplay = display?.openUrl(route: i, param: param, action: action, animation: i == routes.last ? true : false) as? (UIViewController & butterflyDisplay)
                    if let newdisplay{
                        display = newdisplay
                    }
                    
                }
            }
        }
        return true
    }
    
}
