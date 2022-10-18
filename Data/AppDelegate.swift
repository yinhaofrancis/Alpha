//
//  AppDelegate.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        RSScreenConfigration.shared().designSize = CGSize(width: 414, height: 480)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
