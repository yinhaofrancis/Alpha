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

    @StoryboardButterfly(storyboard: "m")
    var vc:UIViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BR.register {
            #if DEBUG
            PathRouter(name: "mmm", cls: VVV.self)
            #else
            Router(proto: mmm.self, cls: VV.self)
            #endif
        }
        self.vc?.bindParam(param: ["nnn":"ggg","aa":1.0])
        self.window = UIWindow()
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = self.vc
        
        
        return true
    }
}

