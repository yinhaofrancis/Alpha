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

    BINavigationRoute *rb = [BINavigationRoute url:[NSURL URLWithString:@"/BINavigation/vMark?a=1"]];
    [self.navi present:rb onWindow:self.window];
    [self.window makeKeyAndVisible];
    return YES;
}


@end

BIPathRouter(UIViewController, "/Mark", UINavigationController)
BIPathRouter(UIViewController, "/Marks", UIViewController)

