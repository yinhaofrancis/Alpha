//
//  BIModule.h
//   
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface BIModuleManager : NSObject
#pragma mark - singlton
+(instancetype)shared;

#pragma mark - register
- (void)regModuleBaseClass:(Class)baseClass WithName:(NSString *)name implement:(Class)cls;

- (void)regModuleWithName:(NSString *)name implement:(Class)cls;

- (void)regModuleWithProtocol:(Protocol *)proto implement:(Class)cls;

#pragma mark - init instance
- (nullable id)getInstanceByProtocol:(Protocol *)proto baseClass:(Class)cls;

- (nullable id)getInstanceByProtocol:(Protocol *)proto;

#pragma mark - 模块装配

- (void)assignAllModule:(id<NSObject>)object;

#pragma mark - target & action

- (id)performTarget:(NSString *)name selector:(NSString *)selector param:(NSArray *)arrays;

- (id)performTarget:(NSString *)name baseClass:(nullable Class)cls selector:(NSString *)selector param:(NSArray *)arrays;

- (id)performTarget:(NSString *)name selector:(NSString *)selector params:(id)args,... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - query

- (nullable Class)getInstanceClassByName:(NSString *)name baseClass:(nullable Class)cls;

- (nullable Class)getInstanceClassByProtocol:(Protocol *)proto baseClass:(nullable Class)cls;

- (NSArray<id> *)allSingltenObject;

@end

typedef NSString* Route;

@interface NSObject (BIM)

#pragma mark - property

@property (readonly)Route bi_route;

@property (nullable,readonly) NSDictionary *bi_params;

#pragma mark - init instance

+ (nullable instancetype)getInstanceByProtocol:(Protocol *)proto;

+ (nullable instancetype)getInstanceByName:(Route)name params:(nullable NSDictionary *)params;

#pragma mark - target & action

+ (id)performTarget:(Route)name selector:(NSString *)selector params:(id)param,... NS_REQUIRES_NIL_TERMINATION;

@end

BIModuleManager * _Nonnull BIM(void);

NS_ASSUME_NONNULL_END

