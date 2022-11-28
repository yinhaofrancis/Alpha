//
//  AppDelegate.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import "AppDelegate.h"


@import Bit;

@interface AppDelegate ()
@property (nonatomic,strong) UIViewController<BINavigator> *rootNavi;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.rootNavi = BIInstantProtocolWithClass(BINavigator,UIViewController);
    self.window = [[UIWindow alloc] init];
    UINavigationController* nv = [UINavigationController getInstanceByName:@"/Mark" params:nil];
    self.window.rootViewController = nv;
    UIViewController * vc = [UIViewController getInstanceByName:@"/vMark" params:nil];
    [nv pushViewController:vc animated:true];
    
//    self.window.rootViewController = self.rootNavi;
    [self.window makeKeyAndVisible];
    return YES;
}


@end

BIPathRouter(UINavigationController, "/Mark", UINavigationController)
BIPathRouter(UIViewController, "/Marks", UIViewController)

