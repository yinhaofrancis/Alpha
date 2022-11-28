//
//  AppDelegate.swift
//  example
//
//  Created by hao yin on 2022/11/3.
//

import UIKit
import butterfly

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    @PathButterfly(name: "/test")
    var rootVC:UIViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BR.register(route: PathRouter(name: "/test", cls: ViewController.self));
        self.rootVC?.bindParam(param: ["nnn":"ggg","aa":Float(1)])
        self.window = UIWindow()
        self.window?.rootViewController = self.rootVC
        self.window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle


}

