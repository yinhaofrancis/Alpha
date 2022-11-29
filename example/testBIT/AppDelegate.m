//
//  AppDelegate.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import "AppDelegate.h"


@import Bit;

@interface AppDelegate ()
@property (nonatomic,strong) id<BINavigation> navi;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.;
    self.navi = [BIM() getInstanceByProtocol:@protocol(BINavigation)];
    self.window = [[UIWindow alloc] init];
    [self.navi pushNavigator:@"BINavigation" window:self.window baseClass:UINavigationController.class];
    [self.navi showWithRoute:@"/vMark" param:nil animation:true];
    [self.window makeKeyAndVisible];
    return YES;
}


@end

BIPathRouter(UINavigationController, "/Mark", UINavigationController)
BIPathRouter(UIViewController, "/Marks", UIViewController)

