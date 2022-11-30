//
//  Navi.h
//  Bit
//
//  Created by wenyang on 2022/11/26.
//

#import <UIKit/UIkit.h>
#import "BINavigationRoute.h"
NS_ASSUME_NONNULL_BEGIN

@protocol BINavigator <NSObject>

#pragma mark - push & pop

- (void)showViewControllers:(NSArray<UIViewController *>*)viewControllers withAnimation:(BOOL)anim;

- (void)showViewController:(UIViewController *)viewControllers withAnimation:(BOOL)anim;

- (void)backToViewController:(nullable UIViewController *)viewControllers withAnimation:(BOOL)anim;

- (void)backToRootWithAnimation:(BOOL)anim;

#pragma mark - present

- (void)present:(nullable UIViewController *)viewController withAnimation:(BOOL)anim;

- (void)dismissWithAnimation:(BOOL)anim;

#pragma mark - children view controllers

@property (nonatomic,readonly)NSArray<UIViewController *> * viewControllerStack;

@end


@protocol BINavigation <NSObject>
#pragma mark - get View Controller
- (nullable UIViewController *)getViewControllerWithProto:(Protocol *)proto;

- (nullable UIViewController *)getViewControllerWithRoute:(BINavigationRoute *)route;

- (nullable UIViewController *)quertCurrentNavigatorStack:(NSString *)routeOrProto;

#pragma mark - present

- (nullable UIViewController *)presentByProto:(nonnull Protocol *)proto animation:(BOOL)animation;

- (void)present:(BINavigationRoute *)route withAnimation:(BOOL)anim;

- (void)present:(nonnull BINavigationRoute *)route onWindow:(UIWindow*)window;

- (void)dismissAnimation:(BOOL)animation;

#pragma mark - push & pop

- (nullable UIViewController *)showWithProto:(Protocol *)proto animation:(BOOL)animation;

- (nullable UIViewController *)showWithProto:(Protocol *)proto replaceCurrent:(BOOL)current animation:(BOOL)animation;

- (void)showWithRoute:(Route)routeName replaceCurrent:(BOOL)current param:(nullable NSDictionary *)param animation:(BOOL)animation;

- (void)showWithRoute:(Route)routeName param:(nullable NSDictionary *)param animation:(BOOL)animation;

- (void)backWithAnimation:(BOOL)animation;

- (void)backToRootWithAnimation:(BOOL)animation;

- (void)backTo:(nullable Route)routeOrProto animation:(BOOL)animation;


@end




NS_ASSUME_NONNULL_END
