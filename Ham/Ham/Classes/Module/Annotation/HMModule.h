//
//  HMModule.h
//  Himalaya
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HMModuleMemoryType) {
    HMModuleSinglten,
    HMModuleWeakSinglten,
    HMModuleNew,
};
@protocol HMModule <NSObject>
+ (HMModuleMemoryType) memoryType;

@optional
+(BOOL) isAsync;
@property (nonatomic,copy) NSString *name;
- (instancetype)initWithParam:(NSDictionary *)param;
@end

@protocol HMModuleThreadConfigure <NSObject>

@optional
+ (const char *) qosName;

+ (dispatch_queue_attr_t) queueAttribute;

+ (qos_class_t) globalQos;

@end

//typedef void(^HMCallBackModuleCallback)( NSDictionary* _Nullable param,id _Nullable sender);
//
//@protocol HMCallBackModule <NSObject>
//@optional
//- (void)callbackName:(nullable NSString*)name
//               param:(nullable NSDictionary *)dic
//              object:(nullable id)object;
//
//- (void)handleObserver:(nullable NSString*)name
//                object:(nullable id)object
//              callback:(HMCallBackModuleCallback)callback;
//
//@end
NS_ASSUME_NONNULL_END

