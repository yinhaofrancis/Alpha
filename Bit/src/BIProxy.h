//
//  BIProxy.h
//  kaka
//
//  Created by KnowChat02 on 2019/7/16.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BIAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ProxyMatchType) {
    ProxyMatchAll,
    ProxyMatchFirst,
};

@interface BIProxy : NSProxy

@property(nonatomic,nullable) dispatch_queue_t queue;

@property(nonatomic,readonly) dispatch_semaphore_t lock;

@property(nonatomic,readonly) id object;

- (instancetype)initWithObject:(id)object;

- (instancetype)initWithQueue:(nullable dispatch_queue_t)queue withObject:(id)object;

- (void)getObject:(void (^)(id _Nullable,BOOL))callback
NS_SWIFT_ASYNC_THROWS_ON_TRUE(2)
NS_SWIFT_ASYNC_NAME("BIProxy.gObject(_:)");

@end



NS_ASSUME_NONNULL_END
