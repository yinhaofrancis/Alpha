//
//  HMWindowManager.h
//  chufeng
//
//  Created by KnowChat02 on 2019/5/16.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMWindow.h"
#import "HMModule.h"

@protocol HMWindowObject;
@class HMWindow;

NS_ASSUME_NONNULL_BEGIN
@protocol HMWindowManager<NSObject>

@property (nonatomic, readonly) UIWindow* currentwindow;
@property(nonatomic,readonly) NSMutableArray<id<HMWindowObject>> *windowObjects;
+ (id<HMWindowManager>)shared;

/// 在当前window上创建Window
/// @param wObject 展示在window 上的对象
/// @param currentWindow 当前window
- (void)showWindow:(id<HMWindowObject>)wObject withCurrentWindow:(nullable UIWindow *)currentWindow;
- (void)replaceWindow:(id<HMWindowObject>)wObject withCurrentWindow:(nullable UIWindow *)currentWindow;

/// 在当前Scene上创建Window
/// @param wObject 展示在window 上的对象
/// @param scene 当前场景
- (void)showWindow:(id<HMWindowObject>)wObject withUIWindowScene:(nullable UIWindowScene *)scene API_AVAILABLE(ios(13.0));
- (void)removeWindow;
- (nullable id<HMWindowObject>)firstWindowObject;

@end
@protocol HMWindowAnimation <NSObject>
@optional
- (void)showAnimation:(HMWindow*)window complete:(void(^)(BOOL flag))handle;
- (void)hideAnimation:(HMWindow*)window complete:(void(^)(BOOL flag))handle;
@end

@interface HMWindowManagerImp : NSObject<HMModule,HMWindowManager>

@end

NS_ASSUME_NONNULL_END

