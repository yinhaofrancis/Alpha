//
//  BIModule.m
//   
//
//  Created by KnowChat02 on 2019/5/31.
//  Copyright © 2019 KnowChat02. All rights reserved.
//
#import <objc/runtime.h>
#import <mach-o/dyld.h>

#import "BIModuleManager.h"
#import "BIModule.h"
#import "BIWeakContainer.h"
#import "BIProxy.h"
#import "BIOCRunTimeTool.h"
#import "NSURL+BIURL.h"
#import "BIAnotationStorage.h"

static BIModuleManager *instance;

static inline void * getRealPtr(void* value);

@implementation BIModuleManager{
    
    NSMutableDictionary<NSString *,Class> *regModules;
    
    NSMutableDictionary<NSString *,id> *singletons;
    
    NSMutableDictionary<NSString *,BIWeakContainer*> *weaksingletons;
    
    dispatch_semaphore_t sem;
}

#pragma mark - init

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

#pragma mark - register

- (void)regModuleBaseClass:(Class)baseClass WithProtocol:(Protocol *)proto implement:(Class)cls{
    [BIAnotationStorage.shared addBaseClass:NSStringFromClass(baseClass) name:NSStringFromProtocol(proto) impClassName:cls];
}
- (void)regModuleWithName:(NSString *)name WithProtocol:(Protocol *)proto implement:(Class)cls{
    [self regModuleWithName:[NSString stringWithFormat:@"%@_%@",name,NSStringFromProtocol(proto)] implement:cls];
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

#pragma mark - init instance

- (id)getInstanceByProtocol:(Protocol *)proto baseClass:(Class)cls{
    return [self getInstanceByName:NSStringFromProtocol(proto) baseClass:cls];
}
- (id)getInstanceByName:(NSString *)name{
    return [self getInstanceByName:name baseClass:nil];
}
- (nullable id)getInstanceByProtocol:(Protocol *)proto withName:(NSString *)name{
    return [self getInstanceByName:[NSString stringWithFormat:@"%@_%@",name,NSStringFromProtocol(proto)] baseClass:nil];
}
- (id)getInstanceByName:(NSString *)name baseClass:(Class)bcls{
    if(name.length == 0){
        return nil;
    }
    Class cls = [self getInstanceClassByName:name baseClass:bcls];
    
    if (bcls != nil && ![cls isSubclassOfClass:bcls]){
        return nil;
    }
    NSString *instKey = bcls == nil ? NSStringFromClass(cls) : [NSString stringWithFormat:@"%@|%@",NSStringFromClass(bcls),NSStringFromClass(cls)];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    id inst = singletons[instKey];
    dispatch_semaphore_signal(sem);
    if(inst == nil){
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        inst = weaksingletons[instKey].content;
        dispatch_semaphore_signal(sem);
    }
    if(inst){
        return inst;
    }else{
        if(cls != nil){
            inst = [cls alloc];
            if ([inst respondsToSelector:@selector(setName:)]){
                [inst setName:name];
            }
            inst = [inst init];
            if([cls conformsToProtocol:@protocol(BIModuleThreadConfigure)]){
                if([cls respondsToSelector:@selector(globalQos)]){
                    dispatch_queue_t q = dispatch_get_global_queue([cls globalQos], 0);
                    inst = [[BIProxy alloc] initWithQueue:q withObject:inst];
                }else{
                    const char* queuename = "";
                    dispatch_queue_attr_t att = DISPATCH_QUEUE_SERIAL;
                    if([cls respondsToSelector:@selector(qosName)]){
                        queuename = [cls qosName];
                    }
                    if([cls respondsToSelector:@selector(queueAttribute)]){
                        att = [cls queueAttribute];
                    }
                    dispatch_queue_t q = dispatch_queue_create(queuename, att);
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
                    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                    singletons[instKey] = inst;
                    dispatch_semaphore_signal(sem);
                }else if([cls memoryType] == BIModuleWeakSinglten){
                    BIWeakContainer* weak = [[BIWeakContainer alloc] init];
                    weak.content = inst;
                    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                    weaksingletons[instKey] = weak;
                    dispatch_semaphore_signal(sem);
                }
            }
            if([inst class] == BIProxy.class){
                BIProxy* proxy = inst;
                [self assignAllModule:proxy.object];
            }else{
                [self assignAllModule:inst];
            }
            return inst;
        }
    }
    return nil;
}

#pragma mark - 模块装配

-(void)assignAllModule:(id<NSObject>)object{
    Class cls = object.class;
    while (cls != [NSObject class] && cls != nil) {
        uint c;
        objc_property_t* ps = class_copyPropertyList(cls, &c);
        for (uint i = 0 ; i < c; i++) {
            uint nn = 0;
            NSString* ivName;
            NSString* type;
            BOOL isCopy = false;
            BOOL isReadonly = false;
            NSString *setter = nil;
            NSString* pname = [[NSString alloc] initWithUTF8String:property_getName(ps[i])];
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
                if([name isEqualToString:@"C"]){
                    isCopy = true;
                }
                if([name isEqualToString:@"R"]){
                    isReadonly = true;
                }
                if([name isEqualToString:@"S"]){
                    setter = [NSString stringWithUTF8String:ac[j].value];
                }
            }
            Ivar iv = class_getInstanceVariable(cls, ivName.UTF8String);
            if(ivName.length > 0 && strlen(ivar_getTypeEncoding(iv)) > 0){
                id objecta = [self parserObject:type name:pname];
                if (isCopy){
                    objecta = [objecta copy];
                }
                if(objecta && iv){
                    object_setIvar(object, iv, objecta);
                }
            }else if(isReadonly == false){
                id objecta = [self parserObject:type name:pname];
                if (objecta){
                    if(setter == nil){
                        setter = [NSString stringWithFormat:@"set%@:",[pname capitalizedString]];
                    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    SEL rSelector = NSSelectorFromString(setter);
                    if([object respondsToSelector:rSelector]){
                        [object performSelector:NSSelectorFromString(setter) withObject:objecta];
                    }
    #pragma clang diagnostic pop
                }
            }
            free(ac);
        }
        cls = class_getSuperclass(cls);
        free(ps);
    }
}

-(id)parserObject:(NSString *)type name:(NSString *)name{
    Class bcls;
    if([type containsString:@"><"]){
        BOOL hasBaseClass = ![type hasPrefix:@"<"];
        NSArray<NSString *> *types = [type componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"><"]];
        NSMutableArray * proto = [NSMutableArray new];
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.length > 0){
                [proto addObject:obj];
            }
        }];
        NSString * baseClass = hasBaseClass ? proto.firstObject : nil;
        if(hasBaseClass){
            [proto removeObject:baseClass];
        }
        if(baseClass == nil){
            NSMutableArray *instance = [NSMutableArray new];
            for (NSString* name in proto) {
                if([self getInstanceClassByName:name baseClass:NSClassFromString(baseClass)]){
                    [instance addObject: [self getInstanceByName:name baseClass:NSClassFromString(baseClass)]];
                }else{
                    return nil;
                }
            }
            return [[BIMultiProxy alloc] initWithObjectNames:instance.copy];
        }else{
            id instance;
            for (NSString* name in proto) {
                if([self getInstanceClassByName:name baseClass:NSClassFromString(baseClass)]){
                    if(instance != nil){
                        if ([instance conformsToProtocol:NSProtocolFromString(name)]){
                            continue;
                        }else{
                            return nil;
                        }
                    }else{
                        instance = [self getInstanceByName:name baseClass:NSClassFromString(baseClass)];
                    }
                }else{
                    return nil;
                }
            }
            return instance;
        }
        
    }else if([type hasPrefix:@"<"] && [type hasSuffix:@">"]){
        type = [type substringWithRange:NSMakeRange(1, type.length - 2)];
    }else if([type containsString:@"<"] && [type hasSuffix:@">"]){
        NSString *temp_type = [type substringWithRange:NSMakeRange(0, type.length - 1)];
        NSArray* temp = [temp_type componentsSeparatedByString:@"<"];
        if(temp.count > 1){
            type = temp[1];
            bcls = NSClassFromString(temp[0]);
        }else{
            return nil;
        }
    }
    if([type hasPrefix:@"<"] && [type hasSuffix:@">"]){
        type = [type substringWithRange:NSMakeRange(1, type.length - 2)];
    }
    NSString* dy = [NSString stringWithFormat:@"%@_%@",name,type];
    
    if([self getInstanceClassByName:dy baseClass:bcls]){
        return [self getInstanceByName:dy baseClass:bcls];
    }
    
    if([self getInstanceClassByName:type baseClass:bcls]){
        return [self getInstanceByName:type baseClass:bcls];
    }
    return nil;
}

#pragma mark - query state

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

#pragma mark - target & action

- (id)performTarget:(NSString *)name selector:(NSString *)selector params:(nonnull id)param,...{
    id objcid = param;
    va_list args;
    NSMutableArray * array = [NSMutableArray new];
    va_start(args, param);
    while (objcid != nil) {
        [array addObject:objcid];
        objcid = va_arg(args, id);
    }
    va_end(args);
    return [self performTarget:name selector:selector param:array];
}

- (id)performTarget:(NSString *)name baseClass:(Class)cls selector:(NSString *)selector params:(nonnull id)param,...{
    id objcid = param;
    va_list args;
    NSMutableArray * array = [NSMutableArray new];
    va_start(args, param);
    while (objcid != nil) {
        [array addObject:objcid];
        objcid = va_arg(args, id);
    }
    va_end(args);
    return [self performTarget:name baseClass:cls selector:selector param:array];
}

- (id)performTarget:(NSString *)name selector:(NSString *)selector param:(NSArray *)arrays{
    return [self performTarget:name baseClass:nil selector:selector param:arrays];
}

- (id)performTarget:(NSString *)name baseClass:(Class)cls selector:(NSString *)selector param:(NSArray *)arrays{
    id target = [self getInstanceByName:name baseClass:cls];
    SEL sel = NSSelectorFromString(selector);
    NSMethodSignature * sign = [target methodSignatureForSelector:sel];
    if(sign == nil){
        @throw [NSException exceptionWithName:@"perform fail" reason:@"invoke target action fail" userInfo:@{@"target":name,@"selector":selector,@"param":arrays}];
    }
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sign];
    invo.target = target;
    [invo setSelector:sel];
    if(sign.numberOfArguments > 2){
        for (int i = 2; i < sign.numberOfArguments; i++){
            id param = arrays[i - 2];
            if([NSNull.null isEqual:param]){
                continue;
            }
            void * temp = malloc(sizeof(void*));
            if ([self typeParamWrap:[sign getArgumentTypeAtIndex:i] value:param result:temp]){
                [invo setArgument:temp atIndex:i];
            }else{
                [invo setArgument:&param atIndex:i];
            }
            free(temp);
        }
    }
    [invo invoke];
    
    const char * retType = sign.methodReturnType;
    if(strcmp(retType, @encode(void)) == 0){
        return nil;
    }
    void * resultPtr = malloc(sign.methodReturnLength);
    [invo getReturnValue:resultPtr];
    id result = [self typeResultWrap:retType value:resultPtr];
    free(resultPtr);
    return result;
}

#pragma mark - type cast

- (BOOL)typeParamWrap:(const char *)retType value:(id)value result:(void *)v{
    if(strcmp(retType, @encode(void)) == 0){
        return true;
    }

    if (strcmp(retType, @encode(char)) == 0) {
        char val = [(NSNumber *) value charValue];
        char *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(int)) == 0) {
        int val = [(NSNumber *) value intValue];
        int *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(short)) == 0) {
        short val = [(NSNumber *) value shortValue];
        short *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(long)) == 0) {
        long val = [(NSNumber *) value longValue];
        long *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(long long)) == 0) {
        long long val = [(NSNumber *) value longLongValue];
        long long *result = v;
        *result = val;
        return true;
    }
    
    if (strcmp(retType, @encode(unsigned char)) == 0) {
        unsigned char val = [(NSNumber *) value unsignedCharValue];
        unsigned char *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(unsigned int)) == 0) {
        unsigned int val = [(NSNumber *) value unsignedIntValue];
        unsigned int *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(unsigned short)) == 0) {
        unsigned short val = [(NSNumber *) value unsignedShortValue];
        unsigned short *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(unsigned long)) == 0) {
        unsigned long val = [(NSNumber *) value unsignedLongValue];
        unsigned long *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(unsigned long long)) == 0) {
        unsigned long long val = [(NSNumber *) value unsignedLongLongValue];
        unsigned long long *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(BOOL)) == 0) {
        BOOL val = [(NSNumber *) value boolValue];
        BOOL *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(float)) == 0) {
        float val = [(NSNumber *) value floatValue];
        float *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(double)) == 0) {
        short val = [(NSNumber *) value shortValue];
        short *result = v;
        *result = val;
        return true;
    }
    if (strcmp(retType, @encode(const char *)) == 0) {
        const char* result = [(NSString*) value UTF8String];
        memcpy(v, &result, sizeof(const char *));
        return true;
    }
    memcpy(v, (__bridge const void *)(value), sizeof(void *));
    return false;
    
}

- (id)typeResultWrap:(const char *)retType value:(void *)value{
    if(strcmp(retType, @encode(void)) == 0){
        return nil;
    }

    if (strcmp(retType, @encode(char)) == 0) {
        char result = *((char *)value);
        
        return @(result);
    }
    if (strcmp(retType, @encode(int)) == 0) {
        int result = *((int *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(short)) == 0) {
        short result = *((short *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(long)) == 0) {
        long result = *((long *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(long long)) == 0) {
        long long result =*((long long  *)value);

        return @(result);
    }
    
    if (strcmp(retType, @encode(unsigned char)) == 0) {
        unsigned char result = *((unsigned char *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(unsigned int)) == 0) {
        unsigned int result = *((unsigned int *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(unsigned short)) == 0) {
        unsigned short result = *((unsigned short *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(unsigned long)) == 0) {
        unsigned long result = *((unsigned long *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(unsigned long long)) == 0) {
        unsigned long long result = *((unsigned long long *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(BOOL)) == 0) {
        BOOL result = *((BOOL *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(float)) == 0) {
        float result = *((float *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(double)) == 0) {
        double result = *((double *)value);

        return @(result);
    }
    if (strcmp(retType, @encode(const char *)) == 0 ||strcmp(retType, @encode(char *)) == 0) {
        char* result = *((char **)value);

        return [[NSString alloc] initWithCString:result encoding:NSASCIIStringEncoding];
    }
    return (__bridge id)getRealPtr(value);
}

@end

const char * routeKey = "__route";

const char * paramsKey = "__params";

@implementation NSObject (BIM)

#pragma mark - property

- (Route)bi_route{
    return objc_getAssociatedObject(self, routeKey);
}
- (NSDictionary *)bi_params{
    return objc_getAssociatedObject(self, paramsKey);
}

#pragma mark - target & action
+ (id)performTarget:(NSString *)name selector:(NSString *)selector params:(id)param,...{
    id objcid = param;
    va_list args;
    NSMutableArray * array = [NSMutableArray new];
    va_start(args, param);
    while (objcid != nil) {
        [array addObject:objcid];
        objcid = va_arg(args, id);
    }
    va_end(args);
    return [BIM() performTarget:name baseClass:[self class] selector:selector param:array];
}

#pragma mark - instace

+ (instancetype)getInstanceByProtocol:(Protocol *)proto{
    id instant = [BIM() getInstanceByProtocol:proto baseClass:[self class]];
    if (instant != nil){
        objc_setAssociatedObject(instant, routeKey, NSStringFromProtocol(proto), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return instant;
}

+ (instancetype)getInstanceByName:(NSString *)name params:(nullable NSDictionary *)params{
    id instant = [BIM() getInstanceByName:name baseClass:[self class]];
    if (instant != nil){
        objc_setAssociatedObject(instant, routeKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject(instant, paramsKey, params, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return instant;
}

@end

inline BIModuleManager * BIM(void){
    return BIModuleManager.shared;
}

static inline void * getRealPtr(void* value){
    return (*(void**)(value));
}
