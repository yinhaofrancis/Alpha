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
    func loadViewController(viewControllers:[UIViewController],animation:Bool)
    func replaceViewController(viewController:[UIViewController],animation:Bool)
    func back(toRoute:String,animation:Bool)
    func back(animation:Bool)
    var currentRoute:String? { get }
}
extension UINavigationController:butterflyDisplay{
    public func back(toRoute: String, animation: Bool) {
        if(toRoute == currentRoute){
            return
        }
        guard let vc = self.viewControllers.reversed().first(where:{ $0.route != nil && $0.route! == toRoute }) else { return }
        self.popToViewController(vc, animated: animation)
    }
    public func replaceViewController(viewController: [UIViewController], animation: Bool) {
        var array = self.viewControllers
        array.removeLast()
        array.append(contentsOf: viewController)
        self.setViewControllers(array, animated: animation)
    }
    
    public func loadViewController(viewController: UIViewController, animation: Bool) {
        self.pushViewController(viewController, animated: animation)
    }

    public func loadViewController(viewControllers vcs: [UIViewController], animation: Bool) {
        var array = self.viewControllers
        array.append(contentsOf: vcs)
        self.setViewControllers(array, animated: animation)
    }

    public func back(animation:Bool) {
        self.popViewController(animated: true)
    }
    
    public var currentRoute: String?{
        self.topViewController?.route
    }
}



public class navigation{
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
        switch(action){
            
        case .show:
            return self.showUrls(routes: routes,param: param,animation: animation)
        case .replace:
            return self.replaceUrls(routes: routes,param: param,animation: animation)
        case .backTo:
            return self.backToUrls(routes: routes,animation: animation)
        case .back:
            return self.back(routes: routes,animation: animation)
        case .dismiss:
            return self.dismiss(routes: routes,animation: animation)
        case .present:
            return self.present(routes: routes,param: param,animation: animation)
        }
    }
    func showUrls(routes:[String],
                 param:[String:Any]? = nil,
                 animation:Bool = true)->Bool{
        var lastVC:UIViewController?
        var vc:[UIViewController] = []
        for i in routes.reversed(){
            if let newVC = self.routeManager.dequeue(route: Route(routeName: i,param: param)){
                lastVC = newVC
                let display:(UIViewController & butterflyDisplay)? = newVC as? (UIViewController & butterflyDisplay)
                if display == nil{
                    vc.insert(newVC, at: 0)
                }else{
                    display?.loadViewController(viewControllers: vc, animation: animation)
                    vc.removeAll()
                    vc.append(newVC)
                }
            }else{
                return false
            }
        }
        
        if self.window.rootViewController == nil{
            self.window.rootViewController = lastVC
        }else if lastVC?.presentingViewController == nil && self.window.rootViewController != lastVC{
            self.window.rootViewController?.present(lastVC!, animated: animation)
        }
        return true
    }
    func replaceUrls(routes:[String],
                 param:[String:Any]? = nil,
                 animation:Bool = true)->Bool{
        var lastVC:UIViewController?
        var vc:[UIViewController] = []
        for i in routes.reversed(){
            if let newVC = self.routeManager.dequeue(route: Route(routeName: i,param: param)){
                lastVC = newVC
                let display:(UIViewController & butterflyDisplay)? = newVC as? (UIViewController & butterflyDisplay)
                if display == nil{
                    vc.insert(newVC, at: 0)
                }else{
                    display?.replaceViewController(viewController: vc, animation: animation)
                    vc.removeAll()
                    vc.append(newVC)
                }
            }else{
                return false
            }
        }
        
        if self.window.rootViewController == nil{
            self.window.rootViewController = lastVC
        }else if lastVC?.presentingViewController == nil{
            self.window.rootViewController?.present(lastVC!, animated: animation)
        }
        return true
    }
    func backToUrls(routes:[String],
                 animation:Bool = true)->Bool{
        for i in routes.reversed(){
            if let newVC = self.routeManager.dequeue(routeName: i){
                let display:(UIViewController & butterflyDisplay)? = newVC as? (UIViewController & butterflyDisplay)
                if display != nil{
                    display?.back(toRoute: routes.last ?? "", animation: animation)
                    return true
                }
            }else{
                return false
            }
        }
        return false
    }
    
    func back(routes:[String],
                 animation:Bool = true)->Bool{
        for i in routes.reversed(){
            if let newVC = self.routeManager.dequeue(routeName: i){
                let display:(UIViewController & butterflyDisplay)? = newVC as? (UIViewController & butterflyDisplay)
                if display != nil{
                    display?.back(animation: animation)
                    return true
                }
            }else{
                return false
            }
        }
        return false
    }
    func dismiss(routes:[String],
                 animation:Bool = true)->Bool{
        for i in routes.reversed(){
            if let newVC = self.routeManager.dequeue(routeName: i){
                let display:(UIViewController & butterflyDisplay)? = newVC as? (UIViewController & butterflyDisplay)
                if display != nil{
                    display?.dismiss(animated: animation)
                    return true
                }
            }else{
                return false
            }
        }
        return false
    }
    func present(routes:[String],
                 param:[String:Any]? = nil,
                 animation:Bool = true)->Bool{
        var lastVC:UIViewController?
        var vc:[UIViewController] = []
        for i in routes.reversed(){
            if let newVC = self.routeManager.dequeue(route: Route(routeName: i,param: param)){
                lastVC = newVC
                let display:(UIViewController & butterflyDisplay)? = newVC as? (UIViewController & butterflyDisplay)
                if display == nil{
                    vc.insert(newVC, at: 0)
                }else{
                    display?.loadViewController(viewControllers: vc, animation: animation)
                    vc.removeAll()
                    vc.append(newVC)
                }
            }else{
                return false
            }
        }
        
        if self.window.rootViewController == nil{
            self.window.rootViewController = lastVC
        }else{
            self.window.rootViewController?.present(lastVC!, animated: animation)
        }
        return true
    }
}

public protocol RouteNavigator{
    
    var window:UIWindow { get }
    
    var currentRouteStack:[(String,WeakContent<UIViewController>)] { get }
    
    var routeStack:[String] { get }
    
    var currentParam:[String:Any]? { get }
    
    func back(route:String?,animation:Bool)
    
    func show(route: String, param: [String : Any]?, animation: Bool)
    
    func replace(route: String, param: [String : Any]?, animation: Bool)
}


public protocol NavigatorDisplay{
    func load(viewControllers:[UIViewController],animation:Bool)
    func load(viewController:UIViewController,animation:Bool)
    func back(viewController:UIViewController?,animation:Bool)
}

public class Controller:RouteNavigator{
    
    public func replace(route: String, param: [String : Any]?, animation: Bool) {
        guard let vc = self.routeManager.dequeue(route: Route(routeName: route, param: param)) else { return }
        var vcs = self.viewControllerStack
        vcs.removeLast()
        vcs.append(vc)
        self.display.load(viewControllers: vcs, animation: animation)
    }
    
    public var routeStack: [String]{
        self.currentRouteStack.map({$0.0})
    }
    
    public var window: UIWindow
    
    public var display:NavigatorDisplay
    
    public var currentRouteStack: [(String, WeakContent<UIViewController>)] = []
    
    private var routeManager:butterfly = butterfly.shared(type: UIViewController.self)
    
    public var viewControllerStack:[UIViewController]{
        return self.currentRouteStack.compactMap(({$0.1.content}))
    }
    
    public var currentParam: [String : Any]?
    
    public func show(route: String, param: [String : Any]?, animation: Bool) {
        guard let vc = self.routeManager.dequeue(route: Route(routeName: route, param: param)) else { return }
        self.currentRouteStack.append((route,WeakContent(content: vc)))
        self.display.load(viewController: vc, animation: animation)
    }
    
    public func back(route: String?, animation: Bool) {
        if let r = route{
            guard let vc = currentRouteStack.reversed().first(where: {$0.0 == r})?.1.content else { return }
            self.display.back(viewController: vc, animation: animation)
        }else{
            self.display.back(viewController: nil, animation: animation)
        }
        
    }
    
    public init(window: UIWindow,display:NavigatorDisplay) {
        self.window = window
        self.display = display
    }
}
