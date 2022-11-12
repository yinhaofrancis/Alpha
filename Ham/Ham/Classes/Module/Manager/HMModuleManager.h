//
//  HMModule.h
//  Himalaya
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMModuleManager : NSObject

+(instancetype)shared;

- (void)regModuleWithName:(NSString *)name implement:(Class)cls;

- (void)regModuleWithProtocol:(Protocol *)proto implement:(Class)cls;

- (nullable id)getInstanceByName:(NSString *)name;

- (nullable id)getInstanceByName:(NSString *)name withParam:(nullable NSDictionary*)param;

- (nullable id)getInstanceByProtocol:(Protocol *)proto;

- (void)cleanInstanceByName:(NSString *)name;

- (void)cleanInstanceByProtocol:(Protocol *)proto;

- (NSArray<id> *)allSingltenObject;

- (nullable Class)getInstanceClassByName:(NSString *)name;

- (nullable Class)getInstanceClassByProtocol:(Protocol *)proto;

- (void)assignAllModule:(id<NSObject>)object;

@end

NS_ASSUME_NONNULL_END
