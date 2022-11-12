//
//  HMProxy.m
//  kaka
//
//  Created by KnowChat02 on 2019/7/16.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "HMProxy.h"
#import <objc/runtime.h>
@implementation HMProxy
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if([self.object respondsToSelector:sel]){
        id a = [self.object methodSignatureForSelector:sel];
        return a;
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    invocation.target = self.object;
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
            [invocation invoke];
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
//- (Class)class {
//    return [self.object class];
//}
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
