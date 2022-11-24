//
//  BIProxy.m
//  kaka
//
//  Created by KnowChat02 on 2019/7/16.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "BIProxy.h"
#import <objc/runtime.h>

#import "BIOCRuntimeTool.h"


NSString * const BIProxyRunloopMode = @"BIProxyRunloop";

@implementation BIProxy
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if([self.object respondsToSelector:sel]){
        id a = [self.object methodSignatureForSelector:sel];
        return a;
    }
    if(self.proto){
        [BIOCRuntimeTool classImplamentProtocol:self.proto selector:sel toClass:self.class imp:^(id obj){
            
        }];
        struct objc_method_description des = protocol_getMethodDescription(self.proto, sel, false, true);
        return [NSMethodSignature signatureWithObjCTypes:des.types];
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    if([self.object respondsToSelector:invocation.selector]){
        invocation.target = self.object;
    }else{
        invocation.target = self;
    }
    
    if (self.queue) {
        void* v = dispatch_get_specific("self");
        if(v == (__bridge void *)(self)){
            [invocation invoke];
            return;
        }
        if(strcmp(invocation.methodSignature.methodReturnType, "v") == 0 && invocation.methodSignature.numberOfArguments > 1){
            [invocation retainArguments];
             dispatch_async(self.queue, ^{
                 [invocation invoke];
             });
        }else{
            dispatch_sync(self.queue, ^{
                [invocation invoke];
            });
        }
    }else{
       [invocation invoke];
    }
}
- (instancetype)initWithObject:(id)object protocol:(nullable Protocol *)proto{
    return [self initWithQueue:nil withObject:object protocol:proto];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue withObject:(nonnull id)object protocol:(nullable Protocol *)proto{
    self->_object = object;
    self.queue = queue;
    self->_proto = proto;
    if(self.queue){
        dispatch_queue_set_specific(self.queue, "self", (__bridge void * _Nullable)(self), NULL);
    }
    _lock = dispatch_semaphore_create(1);
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [self.object respondsToSelector:aSelector];
}

- (NSString *)description {
    return [self.object description];
}
- (NSString *)debugDescription {
    return self.debugDescription;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    return [self.object conformsToProtocol:aProtocol];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [self.object isKindOfClass:aClass];
}
- (BOOL)isMemberOfClass:(Class)aClass{
    return [self isMemberOfClass:aClass];
}
@end

@implementation BIWrap

- (instancetype)initWithObject:(id)object{
    self->_object = object;
    NSString *str = [NSString stringWithFormat:@"%@:%@",NSStringFromClass([object class]),@(self.hash)];
    self->_cls = objc_duplicateClass([object class], str.UTF8String, 0);
    object_setClass(_object, _cls);
    
    return self;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if([self.object respondsToSelector:sel]){
        id a = [self.object methodSignatureForSelector:sel];
        return a;
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:self.object];
}

- (BOOL)overrideMethod:(SEL)seletor callback:(id)callback{
    Method m = class_getInstanceMethod(self.cls, seletor);
    if (m){
        return [BIOCRuntimeTool addMethodToClass:self.cls selector:seletor withType:method_getTypeEncoding(m) imp:callback];
    }
    return false;
}
@end
