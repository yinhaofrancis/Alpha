//
//  BIModule.h
//   
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define BI_FORMAT(F,A) __attribute__((format(id, F, A)))

@interface BIModuleManager : NSObject

+(instancetype)shared;

- (void)regModuleWithName:(NSString *)name implement:(Class)cls;

- (void)regModuleWithProtocol:(Protocol *)proto implement:(Class)cls;

- (nullable id)getInstanceByProtocol:(Protocol *)proto baseClass:(Class)cls;

- (nullable id)getInstanceByProtocol:(Protocol *)proto;

- (NSArray<id> *)allSingltenObject;

- (nullable Class)getInstanceClassByName:(NSString *)name baseClass:(nullable Class)cls;

- (nullable Class)getInstanceClassByProtocol:(Protocol *)proto baseClass:(nullable Class)cls;

- (void)assignAllModule:(id<NSObject>)object;

- (id)performTarget:(NSString *)name selector:(NSString *)selector param:(NSArray *)arrays;

- (id)performTarget:(NSString *)name baseClass:(nullable Class)cls selector:(NSString *)selector param:(NSArray *)arrays;

- (id)performTarget:(NSString *)name selector:(NSString *)selector params:(id)args,... NS_REQUIRES_NIL_TERMINATION;

@end

@interface NSObject (BIM)
+ (id)performTarget:(NSString *)name selector:(NSString *)selector params:(id)param,... NS_REQUIRES_NIL_TERMINATION;

+ (nullable instancetype)getInstanceByProtocol:(Protocol *)proto;

+ (nullable instancetype)getInstanceByName:(NSString *)name params:(nullable NSDictionary *)params;

@end

BIModuleManager * _Nonnull BIM(void);

NS_ASSUME_NONNULL_END

