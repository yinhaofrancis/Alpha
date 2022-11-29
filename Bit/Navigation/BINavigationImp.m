//
//  BINavigationImp.m
//  Bit
//
//  Created by hao yin on 2022/11/29.
//
#import "BIModuleManager.h"

#import "BINavigationImp.h"

#import "BIAnnotation.h"

#import "BIWeakContainer.h"

@implementation BINavigationImp


- (void)backWithAnimation:(BOOL)animation {
    [self backTo:nil animation:animation];
}

- (nullable UIViewController *)getViewControllerWithProto:(nonnull Protocol *)proto {
    return [UIViewController getInstanceByProtocol:proto];
}

- (nullable UIViewController *)getViewControllerWithRoute:(nonnull Route)routeName param:(nullable NSDictionary *)param {
    return [UIViewController getInstanceByName:routeName params:param];
}

- (UIViewController *)showWithProto:(nonnull Protocol *)proto animation:(BOOL)animation {
    return [self showWithProto:proto replaceCurrent:false animation:animation];
}

- (UIViewController *)showWithProto:(nonnull Protocol *)proto replaceCurrent:(BOOL)current animation:(BOOL)animation {
    if(current){
        NSMutableArray<UIViewController *> *vcs = [[[self getTop] viewControllerStack] mutableCopy];
        [vcs removeLastObject];
        UIViewController* vc = [self getViewControllerWithProto:proto];
        [vcs addObject:vc];
        [[self getTop] showViewControllers:vcs withAnimation:animation];
        return vc;
    }else{
        UIViewController* vc = [self getViewControllerWithProto:proto];
        [[self getTop] showViewController:vc withAnimation:animation];
        return vc;
    }
    
}

- (void)backTo:(nullable Route)routeOrProto animation:(BOOL)animation {
    if(routeOrProto){
        UIViewController* vc = [self quertCurrentNavigatorStack:routeOrProto];
        [[self getTop] backToViewController:vc withAnimation:animation];
    }else{
        [[self getTop] backToViewController:nil withAnimation:animation];
    }
}

- (void)showWithRoute:(nonnull Route)routeName param:(nullable NSDictionary *)param animation:(BOOL)animation {
    [self showWithRoute:routeName replaceCurrent:false param:param animation:animation];
}


- (void)showWithRoute:(nonnull Route)routeName replaceCurrent:(BOOL)current param:(nullable NSDictionary *)param animation:(BOOL)animation {
    if(current){
        NSMutableArray<UIViewController *> *vcs = [[[self getTop] viewControllerStack] mutableCopy];
        [vcs removeLastObject];
        UIViewController* vc = [self getViewControllerWithRoute:routeName param:param];
        [vcs addObject:vc];
        [[self getTop] showViewControllers:vcs withAnimation:animation];
    }else{
        UIViewController* vc = [self getViewControllerWithRoute:routeName param:param];
        [[self getTop] showViewController:vc withAnimation:animation];

    }
}

- (void)backToRootWithAnimation:(BOOL)animation {
    [[self getTop] backToRootWithAnimation:animation];
}


- (void)popNavigator {
    [self.stacks removeLastObject];
}


- (void)pushNavigator:(nonnull Route)navigator present:(BOOL)present baseClass:(nonnull Class)cls{
    if(self.stacks == nil){
        self.stacks = [NSMutableArray new];
    }
    UIViewController* vc = [cls getInstanceByName:navigator params:nil];
    
    NSString *msg = [NSString stringWithFormat:@"%@ don not comform BINavigator",navigator];
    NSAssert([vc conformsToProtocol:@protocol(BINavigator)], msg);
    
    if(present){
        [[self getTop] present:vc withAnimation:true];
    }
    [self.stacks addObject:[[BIWeakContainer alloc] initWithContent:vc]];
}
- (void)pushNavigator:(nonnull Route)navigator
               window:(UIWindow*)window
            baseClass:(nonnull Class)cls{
    if(self.stacks == nil){
        self.stacks = [NSMutableArray new];
    }
    UIViewController* vc = [cls getInstanceByName:navigator params:nil];
    
    NSString *msg = [NSString stringWithFormat:@"%@ don not comform BINavigator",navigator];
    NSAssert([vc conformsToProtocol:@protocol(BINavigator)], msg);
    window.rootViewController = vc;
    [self.stacks addObject:[[BIWeakContainer alloc] initWithContent:vc]];
}
- (id<BINavigator>)getTop{
    NSInteger index = self.stacks.count - 1;
    NSMutableArray* empty = [[NSMutableArray alloc] init];
    while (index >= 0) {
        id<BINavigator> current = self.stacks[index].content;
        if (current){
            if(empty.count > 0){
                [empty enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.stacks removeObject:obj];
                }];
            }
            return current;
        }else{
            [empty addObject:self.stacks[index]];
        }
    }
    
    return nil;
}
- (nullable UIViewController *)quertCurrentNavigatorStack:(NSString *)routeOrProto{
    __block UIViewController* vc = nil;
    [[[self getTop] viewControllerStack] enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.route isEqualToString:routeOrProto]){
            vc = obj;
            *stop = true;
        }
    }];
    return  vc;
}

- (void)present:(nonnull Route)route
          param:(nullable NSDictionary *)param
      animation:(BOOL)animation {
    [[self getTop] present:[UIViewController getInstanceByName:route params:param] withAnimation:animation];
}


- (nullable UIViewController *)presentByProto:(nonnull Protocol *)proto animation:(BOOL)animation {
    UIViewController* controller = [UIViewController getInstanceByProtocol:proto];
    [[self getTop] present:controller withAnimation:animation];
    return controller;
}
+ (BIModuleMemoryType)memoryType{
    return BIModuleWeakSinglten;
}
@end

@implementation UINavigationController (BINavigation)

- (void)backToRootWithAnimation:(BOOL)anim {
    [self popToRootViewControllerAnimated:anim];
}

- (void)backToViewController:(nullable UIViewController *)viewControllers withAnimation:(BOOL)anim {
    [self popToViewController:viewControllers animated:anim];
}

- (void)showViewController:(nonnull UIViewController *)viewControllers withAnimation:(BOOL)anim {
    [self pushViewController:viewControllers animated:anim];
}

- (void)showViewControllers:(nonnull NSArray<UIViewController *> *)viewControllers withAnimation:(BOOL)anim {
    [self setViewControllers:viewControllers animated:anim];
}
- (NSArray<UIViewController *> *)viewControllerStack{
    return self.childViewControllers;
}
- (void)present:(nullable UIViewController *)viewController withAnimation:(BOOL)anim{
    [self presentViewController:viewController animated:anim completion:nil];
}



@end

BIPathRouter(UINavigationController, "BINavigation", UINavigationController)
BIService(BINavigation, BINavigationImp)

