//
//  BINavitationViewController.m
//  Bit
//
//  Created by wenyang on 2022/11/26.
//

#import <objc/runtime.h>

#import "BIModuleManager.h"


#import "BINavitationViewController.h"
#import "BINavigator.h"

@interface BINavitationViewController ()<BINavigator>

@end

@implementation BINavitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIViewController *)getViewController:(nonnull Route)route param:(nullable NSDictionary *)params{
    return [UIViewController getInstanceByName:route params:params];
}
- (UIViewController *)queryViewControllerFromStack:(nonnull Route)route{
    NSEnumerator<UIViewController *> * vcs = self.childViewControllers.reverseObjectEnumerator;
    UIViewController* vc = vcs.nextObject;
    while (vc != nil && ![vc.route isEqualToString:route]) {
        vc = vcs.nextObject;
    }
    return vc;
}
- (void)backAnimation:(BOOL)animation {
    [self.navigationController popViewControllerAnimated:animation];
}

- (void)backTo:(nonnull Route)route animation:(BOOL)animation {
    UIViewController* vc = [self queryViewControllerFromStack:route];
    [self popToViewController:vc animated:animation];
}

- (void)replace:(nonnull Route)route animation:(BOOL)animation param:(nullable NSDictionary *)params {
    UIViewController* vc = [self getViewController:route param:params];
    NSMutableArray* vcs = [self.childViewControllers mutableCopy];
    [vcs removeLastObject];
    [vcs addObject:vc];
    [self setViewControllers:vcs animated:animation];
}

- (void)show:(nonnull Route)route animation:(BOOL)animation param:(nullable NSDictionary *)params {
    [self pushViewController:[self getViewController:route param:params] animated:animation];
}

@end

@implementation UIViewController (BINavitationViewController)

- (Route)route{
    return objc_getAssociatedObject(self, "__route");
}
- (void)setRoute:(Route)route{
    return objc_setAssociatedObject(self, "__route", route, OBJC_ASSOCIATION_COPY);
}
@end
