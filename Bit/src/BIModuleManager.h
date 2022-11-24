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

+(instancetype)shared;

- (void)regModuleWithName:(NSString *)name implement:(Class)cls;

- (void)regModuleWithProtocol:(Protocol *)proto implement:(Class)cls;

- (nullable id)getInstanceByUrl:(NSURL *)name;

- (nullable id)getInstanceByProtocol:(Protocol *)proto baseClass:(Class)cls;

- (nullable id)getInstanceByProtocol:(Protocol *)proto;

- (void)cleanInstanceByName:(NSString *)name;

- (void)cleanInstanceByProtocol:(Protocol *)proto;

- (NSArray<id> *)allSingltenObject;

- (nullable Class)getInstanceClassByName:(NSString *)name baseClass:(nullable Class)cls;

- (nullable Class)getInstanceClassByProtocol:(Protocol *)proto baseClass:(nullable Class)cls;

- (void)assignAllModule:(id<NSObject>)object baseClass:(nullable Class)cls;

@end
void dyldPath(void);
NS_ASSUME_NONNULL_END
