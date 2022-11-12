//
//  HMJSConfigure.h
//  chufeng
//
//  Created by KnowChat02 on 2019/7/1.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "HMJSObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface HMJSConfigure : NSObject

@property (nonatomic,nonnull,readonly) WKWebViewConfiguration * configure;
@property (nonatomic,readonly)NSArray<HMJSObject*> *JSObjects;

- (instancetype)initWithConfigure:(WKWebViewConfiguration *)configure;
- (void)addJSObject:(HMJSObject *)object;
- (void)removeJSObject:(HMJSObject *)object;
- (void)injectJSCode:(WKUserScript *)jsCode;
@end

NS_ASSUME_NONNULL_END
