//
//  BIModule.m
//   
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//
#import <objc/runtime.h>


#import "BIModuleManager.h"
#import "BIModule.h"
#import "BIWeakContainer.h"
#import "BIProxy.h"
#import "BIOCRunTimeTool.h"
#import "NSURL+BIURL.h"
#import "BIAnotationStorage.h"

static BIModuleManager *instance;

@implementation BIModuleManager{
    NSMutableDictionary<NSString *,Class> *regModules;
    NSMutableDictionary<NSString *,id> *singletons;
    NSMutableDictionary<NSString *,BIWeakContainer*> *weaksingletons;
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
        instance = [[BIModuleManager alloc] init];
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
- (id)getInstanceByUrl:(NSURL *)name{
    NSString* path = name.path;
    NSDictionary* param = [name bi_param];
    return [self getInstanceByName:path withParam:param];
}
- (id)getInstanceByProtocol:(Protocol *)proto baseClass:(Class)cls{
    return [self getInstanceByName:NSStringFromProtocol(proto) baseClass:cls withParam:nil];
}
- (id)getInstanceByName:(NSString *)name withParam:(NSDictionary *)param{
    return [self getInstanceByName:name baseClass:nil withParam:param];
}
- (id)getInstanceByName:(NSString *)name baseClass:(Class)bcls withParam:(NSDictionary *)param{
    if(name.length == 0){
        return nil;
    }
    Class cls = [self getInstanceClassByName:name baseClass:bcls];
    
    if (bcls != nil && ![cls isSubclassOfClass:bcls]){
        return nil;
    }
    NSString *instKey = bcls == nil ? NSStringFromClass(cls) : [NSString stringWithFormat:@"%@|%@",NSStringFromClass(bcls),NSStringFromClass(cls)];
    id inst = singletons[instKey];
    if(inst == nil){
        inst = weaksingletons[instKey].content;
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
            
            if([cls conformsToProtocol:@protocol(BIModuleThreadConfigure)]){
                if([cls respondsToSelector:@selector(globalQos)]){
                    dispatch_queue_t q = dispatch_get_global_queue([cls globalQos], 0);
                    inst = [[BIProxy alloc] initWithQueue:q withObject:inst];
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
                    inst = [[BIProxy alloc] initWithQueue:q withObject:inst];
                }
               
           }else{
               if ([cls respondsToSelector:@selector(isAsync)]){
                   if([cls isAsync]){
                       dispatch_queue_t q = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
                       inst = [[BIProxy alloc] initWithQueue:q withObject:inst];
                   }
               }
           }
            if([cls respondsToSelector:@selector(memoryType)]){
                if([cls memoryType] == BIModuleSinglten){
                    singletons[instKey] = inst;
                }else if([cls memoryType] == BIModuleWeakSinglten){
                    BIWeakContainer* weak = [[BIWeakContainer alloc] init];
                    weak.content = inst;
                    weaksingletons[instKey] = weak;
                }
            }
            if([inst class] == BIProxy.class){
                BIProxy* proxy = inst;
                [self assignAllModule:proxy.object baseClass:bcls];
            }else{
                [self assignAllModule:inst baseClass:bcls];
            }
            return inst;
        }
    }
    return nil;
}
-(void)assignAllModule:(id<NSObject>)object baseClass:(Class)bcls{
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
                id objecta = [self parserObject:type baseClass:bcls];
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
-(id)parserObject:(NSString *)type baseClass:(Class)bcls{
    if([type hasPrefix:@"<"] && [type hasSuffix:@">"]){
        type = [type substringWithRange:NSMakeRange(1, type.length - 2)];
    }
    Class cls = [self getInstanceClassByName:type baseClass:bcls];
    if(cls){
        return [self getInstanceByName:type];
    }
    return nil;
}

- (BIModuleMemoryType) getMemoryTypeByProtocol:(Protocol *)protocol baseClass:(Class)bcls{
    return  [self getMemoryTypeByName:NSStringFromProtocol(protocol) baseClass:bcls];
}
- (BIModuleMemoryType) getMemoryTypeByName:(NSString*)name baseClass:(Class)bcls{
    Class cls = [self getInstanceClassByName:name baseClass:bcls];
    if(cls){
        return [cls memoryType];
    }else{
        return BIModuleNew;
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
- (Class)getInstanceClassByName:(NSString *)name baseClass:(Class)cls{
    if(cls){
        return [BIAnotationStorage.shared getEnvConfigByName:NSStringFromClass(cls)][name];
    }else{
        return regModules[name];
    }
    
}
- (Class)getInstanceClassByProtocol:(Protocol *)proto baseClass:(Class)cls{
    return [self getInstanceClassByName:NSStringFromProtocol(proto) baseClass:cls];
}
@end
