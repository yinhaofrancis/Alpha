//
//  HMModule.m
//  Himalaya
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "HMModuleManager.h"
#import "HMModule.h"
#import "HMWeakContainer.h"
#import <objc/runtime.h>
#import "HMProxy.h"
#import "HMOCRunTimeTool.h"
static HMModuleManager *instance;

@implementation HMModuleManager{
    NSMutableDictionary<NSString *,Class> *regModules;
    NSMutableDictionary<NSString *,id> *singletons;
    NSMutableDictionary<NSString *,HMWeakContainer*> *weaksingletons;
    dispatch_semaphore_t sem;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        regModules = [[NSMutableDictionary alloc] init];
        singletons = [[NSMutableDictionary alloc] init];
        weaksingletons = [[NSMutableDictionary alloc] init];
        sem = dispatch_semaphore_create(1);
    }
    return self;
}
+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HMModuleManager alloc] init];
    });
    return instance;
}

- (void)regModuleWithName:(NSString *)name implement:(Class)cls {
#if DEBUG
    NSAssert(name.length > 0, @"module name %@ is empty",name);
    NSAssert(cls != nil, @"module name %@ is empty",name);
#endif
    if(name.length == 0 || cls == nil){
        return;
    }
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
#if DEBUG
    NSAssert(!regModules[name], @"module %@ 已存在",name);
#endif
    regModules[name] = cls;
    dispatch_semaphore_signal(sem);
}
- (void)regModuleWithProtocol:(Protocol *)proto implement:(Class)cls {
    [self regModuleWithName:NSStringFromProtocol(proto) implement:cls];
}
- (id)getInstanceByName:(NSString *)name {
    return [self getInstanceByName:name withParam:nil];
}
- (id)getInstanceByName:(NSString *)name withParam:(NSDictionary *)param{
    if(name.length == 0){
        return nil;
    }
    Class cls = [self getInstanceClassByName:name];
    id inst = singletons[NSStringFromClass(cls)];
    if(inst == nil){
        inst = weaksingletons[NSStringFromClass(cls)].content;
    }
    if(inst){
        return inst;
    }else{
        if(cls != nil){
            if(param != nil){
                
                inst = [cls alloc];
                if ([inst respondsToSelector:@selector(setName:)]){
                    [inst setName:name];
                }
                inst = [inst initWithParam:param];
            }else{
                inst = [cls alloc];
                if ([inst respondsToSelector:@selector(setName:)]){
                    [inst setName:name];
                }
                inst = [inst init];
            }
            
            if([cls conformsToProtocol:@protocol(HMModuleThreadConfigure)]){
                if([cls respondsToSelector:@selector(globalQos)]){
                    dispatch_queue_t q = dispatch_get_global_queue([cls globalQos], 0);
                    inst = [[HMProxy alloc] initWithQueue:q withObject:inst];
                }else{
                    const char* name = "";
                    dispatch_queue_attr_t att = DISPATCH_QUEUE_SERIAL;
                    if([cls respondsToSelector:@selector(qosName)]){
                        name = [cls qosName];
                    }
                    if([cls respondsToSelector:@selector(queueAttribute)]){
                        att = [cls queueAttribute];
                    }
                    dispatch_queue_t q = dispatch_queue_create(name, att);
                    inst = [[HMProxy alloc] initWithQueue:q withObject:inst];
                }
               
           }else{
               if ([cls respondsToSelector:@selector(isAsync)]){
                   if([cls isAsync]){
                       dispatch_queue_t q = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
                       inst = [[HMProxy alloc] initWithQueue:q withObject:inst];
                   }
               }
           }
            if([cls respondsToSelector:@selector(memoryType)]){
                if([cls memoryType] == HMModuleSinglten){
                    singletons[NSStringFromClass(cls)] = inst;
                }else if([cls memoryType] == HMModuleWeakSinglten){
                    HMWeakContainer* weak = [[HMWeakContainer alloc] init];
                    weak.content = inst;
                    weaksingletons[NSStringFromClass(cls)] = weak;
                }
            }
            if([inst class] == HMProxy.class){
                HMProxy* proxy = inst;
                [self assignAllModule:proxy.object];
                [self configCallBack:proxy.object];
            }else{
                [self assignAllModule:inst];
                [self configCallBack:inst];
            }
            return inst;
        }
    }
    return nil;
}
-(void)assignAllModule:(id<NSObject>)object{
    Class cls = object.class;
    while (cls != [NSObject class] && cls != nil) {
        uint c;
        objc_property_t* ps = class_copyPropertyList(cls, &c);
        for (uint i = 0 ; i < c; i++) {
            uint nn = 0;
            NSString* ivName;
            NSString* type;
            objc_property_attribute_t * ac = property_copyAttributeList(ps[i], &nn);
            for (uint j = 0; j < nn; j++) {
                NSString* name = [NSString stringWithUTF8String:ac[j].name];
                if([name isEqualToString:@"V"]){
                    ivName = [NSString stringWithUTF8String:ac[j].value];
                }
                if([name isEqualToString:@"T"]){
                    type = [NSString stringWithUTF8String:ac[j].value];
                    if(type.length > 3){
                        
                        type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
                    }else{
                        break;
                    }
                    
                }
            }
            if(ivName.length > 0){
                id objecta = [self parserObject:type];
                Ivar iv = class_getInstanceVariable(cls, ivName.UTF8String);
                if(objecta && iv){
                    object_setIvar(object, iv, objecta);
                }
            }
            free(ac);
            
        }
        cls = class_getSuperclass(cls);
        free(ps);
    }
}
-(id)parserObject:(NSString *)type{
    if([type hasPrefix:@"<"] && [type hasSuffix:@">"]){
        type = [type substringWithRange:NSMakeRange(1, type.length - 2)];
    }
    Class cls = [self getInstanceClassByName:type];
    if(cls){
        return [self getInstanceByName:type];
    }
    return nil;
}

- (HMModuleMemoryType) getMemoryTypeByProtocol:(Protocol *)protocol{
    return  [self getMemoryTypeByName:NSStringFromProtocol(protocol)];
}
- (HMModuleMemoryType) getMemoryTypeByName:(NSString*)name{
    Class cls = [self getInstanceClassByName:name];
    if(cls){
        return [cls memoryType];
    }else{
        return HMModuleNew;
    }
}
- (id)getInstanceByClass:(Class)name{
    return [self getInstanceByName:NSStringFromClass(name)];
}
- (id)getInstanceByProtocol:(Protocol *)proto{
    return [self getInstanceByName:NSStringFromProtocol(proto)];
}
- (void)cleanInstanceByName:(NSString *)name{
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    [singletons removeObjectForKey:name];
    dispatch_semaphore_signal(sem);
}
- (void)cleanInstanceByProtocol:(Protocol *)proto{
    [self cleanInstanceByName:NSStringFromProtocol(proto)];
}
- (NSArray<id> *)allSingltenObject{
    return singletons.allValues;
}
- (Class)getInstanceClassByName:(NSString *)name{
    return regModules[name];
}
- (Class)getInstanceClassByProtocol:(Protocol *)proto{
    return [self getInstanceClassByName:NSStringFromProtocol(proto)];
}

//MARK:callback

- (void)configCallBack:(id<NSObject>)object{
    
}
@end
