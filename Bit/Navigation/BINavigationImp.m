//
//  BINavigationImp.m
//  Bit
//
//  Created by hao yin on 2022/11/29.
//
#import "BIModuleManager.h"

#import "BINavigationImp.h"

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


- (void)pushNavigator:(nonnull id<BINavigator>)navigator {
    if(self.stacks == nil){
        self.stacks = [NSMutableArray new];
    }
    [self.stacks addObject:navigator];
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

@end
