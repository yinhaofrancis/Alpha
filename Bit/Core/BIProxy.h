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


@interface BIProxy : NSProxy

@property(nonatomic,nullable) dispatch_queue_t queue;

@property(nonatomic,readonly) dispatch_semaphore_t lock;

@property(nonatomic,readonly) id object;

@property(nonatomic,readonly) Protocol *proto;

- (instancetype)initWithObject:(id)object protocol:(nullable Protocol*)proto;

- (instancetype)initWithQueue:(nullable dispatch_queue_t)queue withObject:(id)object protocol:(nullable Protocol*)proto;

@end

NS_ASSUME_NONNULL_END
