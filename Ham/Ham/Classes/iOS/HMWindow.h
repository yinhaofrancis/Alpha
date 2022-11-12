//
//  HMWindow.h
//  chufeng
//
//  Created by KnowChat02 on 2019/5/15.
//  Copyright © 2019 KnowChat02. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HMWindowManager.h"

NS_ASSUME_NONNULL_BEGIN
@class HMWindow;
@protocol HMWindowAnimation;
@protocol HMWindowManager;

@protocol HMWindowObject <HMWindowAnimation>
@property (nonatomic,weak) id<HMWindowManager> manager;
- (UIViewController*)rootVC;

@optional
- (BOOL)showKeyWindow;
- (BOOL)userInteractionEnabled;
- (CGFloat)windowLevel;
@end

@interface HMWindow : UIWindow
@property (nonatomic,weak) id<HMWindowAnimation>animation;
- (void)removeSelfComplete:(void(^)(BOOL flag))handle;
- (void)visiableSelfComplete:(void(^)(BOOL flag))handle;
@end

NS_ASSUME_NONNULL_END

