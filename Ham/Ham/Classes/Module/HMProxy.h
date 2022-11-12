//
//  HMProxy.h
//  kaka
//
//  Created by KnowChat02 on 2019/7/16.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ProxyMatchType) {
    ProxyMatchAll,
    ProxyMatchFirst,
};
@interface HMProxy : NSProxy

@property(nonatomic,nullable) dispatch_queue_t queue;

@property(nonatomic,readonly) dispatch_semaphore_t lock;

@property(nonatomic,readonly) id object;

- (instancetype)initWithObject:(id)object;

- (instancetype)initWithQueue:(nullable dispatch_queue_t)queue withObject:(id)object;

@end



NS_ASSUME_NONNULL_END
