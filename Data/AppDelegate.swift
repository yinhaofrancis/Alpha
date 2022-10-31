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
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RouteEdit")
        }))
        UIViewController.register(router: Router<UIViewController>(path: "route", build: {
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Route")
        }))
        UIViewController.register(router: Router<UIViewController>(path: "navi1",mem: .weakSinglton, build: {
            UINavigationController()
        }))
        UIViewController.register(router: Router<UIViewController>(path: "navi2", mem: .weakSinglton, build: {
            UINavigationController()
        }))
        self.window = controller.window
        self.window?.makeKeyAndVisible()
        _ = controller.openUrl(url: URL(string: "/navi1/routeEdit/navi2/route")!)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            _ = controller.openUrl(url: URL(string: "/navi1/route")!)
        }
        return true
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
