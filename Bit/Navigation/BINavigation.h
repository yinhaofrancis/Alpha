//
//  Navi.h
//  Bit
//
//  Created by wenyang on 2022/11/26.
//

#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BINavigator <NSObject>

- (void)showViewControllers:(NSArray<UIViewController *>*)viewControllers withAnimation:(BOOL)anim;

- (void)showViewController:(UIViewController *)viewControllers withAnimation:(BOOL)anim;

- (void)backToViewController:(nullable UIViewController *)viewControllers withAnimation:(BOOL)anim;

- (void)backToRootWithAnimation:(BOOL)anim;

@property (nonatomic,readonly)NSArray<UIViewController *> * viewControllerStack;

@end


@protocol BINavigation <NSObject>

- (nullable UIViewController *)getViewControllerWithProto:(Protocol *)proto;

- (nullable UIViewController *)getViewControllerWithRoute:(Route)routeName param:(nullable NSDictionary *)param;

- (nullable UIViewController *)showWithProto:(Protocol *)proto replaceCurrent:(BOOL)current animation:(BOOL)animation;

- (void)showWithRoute:(Route)routeName replaceCurrent:(BOOL)current param:(nullable NSDictionary *)param animation:(BOOL)animation;

- (nullable UIViewController *)showWithProto:(Protocol *)proto animation:(BOOL)animation;

- (void)showWithRoute:(Route)routeName param:(nullable NSDictionary *)param animation:(BOOL)animation;
 
- (void)backTo:(nullable Route)routeOrProto animation:(BOOL)animation;

- (void)backWithAnimation:(BOOL)animation;

- (void)backToRootWithAnimation:(BOOL)animation;

- (void)pushNavigator:(id<BINavigator>)navigator;

- (void)popNavigator;

- (nullable UIViewController *)quertCurrentNavigatorStack:(NSString *)routeOrProto;

@end




NS_ASSUME_NONNULL_END
