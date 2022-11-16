//
//  BIModule.h
//   
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BIModuleMemoryType) {
    BIModuleSinglten,
    BIModuleWeakSinglten,
    BIModuleNew,
};
@protocol BIModule <NSObject>
+ (BIModuleMemoryType) memoryType;

@optional

+(BOOL) isAsync;

@property (nonatomic,copy) NSString *name;

- (instancetype)initWithParam:(NSDictionary<NSString *,NSString *> *)param;

@end

@protocol BIModuleThreadConfigure <NSObject>

@optional
+ (const char *) qosName;

+ (dispatch_queue_attr_t) queueAttribute;

+ (qos_class_t) globalQos;

@end
NS_ASSUME_NONNULL_END

