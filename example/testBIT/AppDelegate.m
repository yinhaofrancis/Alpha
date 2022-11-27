//
//  AppDelegate.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import "AppDelegate.h"

#import "BINavigator.h"
#import "BIModuleManager.h"
#import "BIAnnotation.h"

@interface AppDelegate ()
@property (nonatomic,strong) UIViewController<BINavigator> *rootNavi;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.rootNavi = BIInstantProtocolWithClass(BINavigator,UIViewController);
//    self.window = [self.rootNavi window:@"/mark" newNavigator:true];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
