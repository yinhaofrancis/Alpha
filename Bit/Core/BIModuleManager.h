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
/// 注册
/// - Parameters:
///   - baseClass: 积累用于类型检查
///   - proto: 协议
///   - cls: 模块类
- (void)regModuleBaseClass:(Class)baseClass WithProtocol:(Protocol *)proto implement:(Class)cls;

/// 注册
/// - Parameters:
///   - name: 模块名字
///   - cls: 模块类
- (void)regModuleWithName:(NSString *)name implement:(Class)cls;

/// 注册
/// - Parameters:
///   - name:模块名字
///   - proto: 协议
///   - cls: 模块类
- (void)regModuleWithName:(NSString *)name WithProtocol:(Protocol *)proto implement:(Class)cls;
/// 注册
/// - Parameters:
///   - proto: 协议
///   - cls: 实现协议模块的类
- (void)regModuleWithProtocol:(Protocol *)proto implement:(Class)cls;

#pragma mark - init instance
/// 获取模块
/// - Parameters:
///   - proto: 协议
///   - cls: 基类
- (nullable id)getInstanceByProtocol:(Protocol *)proto baseClass:(Class)cls;

/// 获取模块
/// - Parameter proto: 协议
- (nullable id)getInstanceByProtocol:(Protocol *)proto;

/// 获取模块
/// - Parameter proto: 协议
/// - Parameter name: 模块名
- (nullable id)getInstanceByProtocol:(Protocol *)proto withName:(NSString *)name;

#pragma mark - 模块装配

/// 装配模块依赖的模块
/// - Parameter object: 模块对象
- (void)assignAllModule:(id)object;

#pragma mark - target & action

/// 调用模块方法
/// - Parameters:
///   - name: 模块名
///   - selector: selector
///   - arrays: 参数列表
- (id)performTarget:(NSString *)name selector:(NSString *)selector param:(NSArray *)arrays;

/// 调用模块方法
/// - Parameters:
///   - name: 模块名
///   - cls: 基类
///   - selector: selector
///   - arrays: 参数列表
- (id)performTarget:(NSString *)name baseClass:(nullable Class)cls selector:(NSString *)selector param:(NSArray *)arrays;

/// 调用模块方法
/// - Parameters:
///   - name: 模块名
///   - selector: selector
///   - args: 参数
- (id)performTarget:(NSString *)name selector:(NSString *)selector params:(id)args,... NS_REQUIRES_NIL_TERMINATION;


/// 调用模块方法
/// - Parameters:
///   - name: 模块名
///   - cls: 基类
///   - selector: selector
///   - arrays: 参数列表
- (id)performTarget:(NSString *)name baseClass:(nullable Class)cls selector:(NSString *)selector params:(id)args,... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - query

/// 获取注册的类
/// - Parameters:
///   - name: 类名
///   - cls: 基类
- (nullable Class)getInstanceClassByName:(NSString *)name baseClass:(nullable Class)cls;

/// 获取注册的类
/// - Parameters:
///   - proto: 协议
///   - cls: 基类
- (nullable Class)getInstanceClassByProtocol:(Protocol *)proto baseClass:(nullable Class)cls;

/// 单例列表
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

