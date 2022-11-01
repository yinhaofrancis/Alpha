//
//  AppDelegate.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import butterfly
public var controller:Controller = Controller(window: UIWindow(frame: UIScreen.main.bounds))
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIViewController.register(router: Router<UIViewController>(path: "routeEdit", build: {
            let v = RouteEditViewController()
            v.view.backgroundColor = UIColor.systemOrange
            v.title = "routeEdit"
            return v
        }))
        UIViewController.register(router: Router<UIViewController>(path: "route", build: {
            let v = UIViewController()
            v.view.backgroundColor = UIColor.systemPurple
            v.title = "route"
            return v
        }))
        
        UIViewController.register(router: Router<UIViewController>(path: "route2", build: {
            let v = UIViewController()
            v.view.backgroundColor = UIColor.gray
            v.title = "route2"
            return v
        }))
        UIViewController.register(router: Router<UIViewController>(path: "navi1",mem: .weakSinglton, build: {
            UINavigationController()
        }))
        UIViewController.register(router: Router<UIViewController>(path: "navi2", mem: .weakSinglton, build: {
            let navi = UINavigationController()
            return navi
        }))
        
        self.window = controller.window
        self.window?.makeKeyAndVisible()
        _ = controller.openUrl(url: URL(string: "/navi1/route2/routeEdit/route/route2/route")!)
        
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
            _ = controller.openUrl(url: URL(string: "/navi1/route2/route/route/route")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            _ = controller.openUrl(url: URL(string: "/navi2/route2")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            _ = controller.openUrl(url: URL(string: "/navi2/routeEdit#replace")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            _ = controller.openUrl(url: URL(string: "/navi2/routeEdit#dismiss")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) {
            _ = controller.openUrl(url: URL(string: "/navi1/routeEdit#backTo")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) {
            _ = controller.openUrl(url: URL(string: "/navi1#back")!)
        }
//
        return true
    }
    @objc func close(){
        
    }
}

@propertyWrapper
public class State<T>{
    public var wrappedValue: T
    public init(wrappedValue:T){
        self.wrappedValue = wrappedValue
    }
}

public struct V{
    
    
    @State
    var name:String = ""
    
    
    func m(){
        self.name = "dasda"
    }
}


public protocol makeModule{
    func make()
}

public class TestModule:makeModule{
    public func make() {
        print("make");
    }
}
