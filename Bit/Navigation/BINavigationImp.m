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
#pragma mark - init
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stacks = [NSMutableArray new];
    }
    return self;
}
#pragma mark - get viewController
- (nullable UIViewController *)getViewControllerWithProto:(nonnull Protocol *)proto {
    return [UIViewController getInstanceByProtocol:proto];
}

- (nullable UIViewController *)getViewControllerWithRoute:(nonnull BINavigationRoute *)route {
    UIViewController<BINavigator> *top = (UIViewController<BINavigator>*)[UIViewController getInstanceByName:route.route params:route.param];
    UIViewController<BINavigator> *current = top;
    BINavigationRoute *currentRoute= route;
    while (top != nil && currentRoute.next != nil && [current conformsToProtocol:@protocol(BINavigator)]) {
        currentRoute = route.next;
        UIViewController* next = [UIViewController getInstanceByName:currentRoute.route params:currentRoute.param];
        [current showViewController:next withAnimation:false];
        current = (UIViewController<BINavigator> *)next;
        
    }
    return top;
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

#pragma mark - push & pop


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

- (void)backWithAnimation:(BOOL)animation {
    [self backTo:nil animation:animation];
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
        
        UIViewController* vc = [self getViewControllerWithRoute:[BINavigationRoute.alloc initWithRoute:routeName param:param next:nil]];
        [vcs addObject:vc];
        [[self getTop] showViewControllers:vcs withAnimation:animation];
    }else{
        UIViewController* vc = [self getViewControllerWithRoute:[BINavigationRoute.alloc initWithRoute:routeName param:param next:nil]];
        [[self getTop] showViewController:vc withAnimation:animation];

    }
}

- (void)backToRootWithAnimation:(BOOL)animation {
    [[self getTop] backToRootWithAnimation:animation];
}



#pragma mark - present
- (nullable UIViewController *)presentByProto:(nonnull Protocol *)proto animation:(BOOL)animation {
    UIViewController* controller = [UIViewController getInstanceByProtocol:proto];
    [[self getTop] present:controller withAnimation:animation];
    if([controller conformsToProtocol:@protocol(BINavigator)]){
        [self.stacks addObject:[BIWeakContainer.alloc initWithContent:controller]];
    }
    return controller;
}

- (void)present:(nonnull BINavigationRoute *)route withAnimation:(BOOL)anim {
    UIViewController* controller = [self getViewControllerWithRoute:route];
    [[self getTop] present:controller withAnimation:anim];
    if([controller conformsToProtocol:@protocol(BINavigator)]){
        [self.stacks addObject:[BIWeakContainer.alloc initWithContent:controller]];
    }
}

- (void)present:(nonnull BINavigationRoute *)route onWindow:(UIWindow*)window{
    UIViewController* controller = [self getViewControllerWithRoute:route];
    window.rootViewController = controller;
    if([controller conformsToProtocol:@protocol(BINavigator)]){
        [self.stacks addObject:[BIWeakContainer.alloc initWithContent:controller]];
    }
}

- (void)dismissAnimation:(BOOL)animation {
    [[self getTop] dismissWithAnimation:animation];
}

#pragma mark - memory
+ (BIModuleMemoryType)memoryType{
    return BIModuleWeakSinglten;
}

#pragma mark - private
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

- (void) removeTop{
    [[self stacks] removeLastObject];
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

- (void)dismissWithAnimation:(BOOL)anim {
    [self dismissViewControllerAnimated:anim completion:nil];
}


@end




BIPathRouter(UIViewController, "BINavigation", UINavigationController)
BIService(BINavigation, BINavigationImp)

