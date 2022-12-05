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
- (instancetype)initWithObject:(id)object{
    return [self initWithQueue:nil withObject:object];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue withObject:(nonnull id)object{
    self->_object = object;
    self.queue = queue;
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
    return [self.object isMemberOfClass:aClass];
}
@end

@implementation BIMultiProxy

- (instancetype)initWithObjectNames:(NSArray<NSString *> *)objects{
    _objects = objects;
    return self;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    for (id i in self.objects) {
        if([i respondsToSelector:sel]){
            id a = [i methodSignatureForSelector:sel];
            return a;
        }
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    for (id i in self.objects) {
        if([i respondsToSelector:invocation.selector]){
            [invocation invokeWithTarget:i];
        }
    }
}
- (BOOL)respondsToSelector:(SEL)aSelector{
    for (id i in self.objects) {
        if ([i respondsToSelector:aSelector]){
            return true;
        }
    }
    return false;
}

- (NSString *)description {
    return [self.objects description];
}
- (NSString *)debugDescription {
    return self.objects.debugDescription;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    for (id i in self.objects) {
        if ([i conformsToProtocol:aProtocol]){
            return true;
        }
    }
    return false;
}

- (BOOL)isKindOfClass:(Class)aClass {
    for (id i in self.objects) {
        if ([i isKindOfClass:aClass]){
            return true;
        }
    }
    return false;
}
- (BOOL)isMemberOfClass:(Class)aClass{
    for (id i in self.objects) {
        if ([i isMemberOfClass:aClass]){
            return true;
        }
    }
    return false;
}
@end
