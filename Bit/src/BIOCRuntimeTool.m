//
//  BIOCRunTimeTool.m
//  Ham
//
//  Created by KnowChat02 on 2019/10/24.
//

#import "BIOCRuntimeTool.h"

@implementation BIOCRuntimeTool
+ (void)assignIVar:(NSDictionary<NSString *,id> *)kv ToObject:(id)object{
    
    Class cls = [object class];
    while (cls != [NSObject class] && cls != nil) {
        uint c;
        Ivar * v = class_copyIvarList(cls, &c);
        for (int i = 0; i < c; i ++) {
            NSString *s = [[NSString alloc] initWithUTF8String:ivar_getName(v[i])];
            if([kv.allKeys containsObject:s]){
                object_setIvar(object, v[i], kv[s]);
            }
        }
        free(v);
        cls = class_getSuperclass(cls);
    }
}

+ (Protocol *)createProtocolWithName:(NSString *)name
                                from:(Protocol *)protocol
                           implement:(NSDictionary<NSString *,NSString *> *)kv{
    Protocol* newProtocol = objc_allocateProtocol(name.UTF8String);
    if(newProtocol){
        protocol_addProtocol(newProtocol, protocol);
        for (int i = 0 ; i < kv.count; i++) {
            
            protocol_addMethodDescription(newProtocol,NSSelectorFromString(kv.allKeys[i]) , kv[kv.allKeys[i]].UTF8String, false, true);
        }
        
        objc_registerProtocol(newProtocol);
    }
    
    return newProtocol;
}
+ (void)modifyClass:(id)object cls:(Class)cls{
    object_setClass(object,cls);
}
+(void)swizzing:(SEL)originalSelector
           with:(SEL)swizzledSelector
            cls:(Class)className{
    Method originalMethod = class_getInstanceMethod(className, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(className, swizzledSelector);

    BOOL didAddMethod = class_addMethod(
                                        className,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod)
                                        );
    if (didAddMethod) {
       class_replaceMethod(
                           className,
                           swizzledSelector,
                           method_getImplementation(originalMethod),
                           method_getTypeEncoding(originalMethod)
                           );
    } else {
       method_exchangeImplementations(
                                      originalMethod,
                                      swizzledMethod);
    }
}

+ (NSArray<NSString *> *)propertyInClass:(Class)cls{
    uint c = 0;
    NSMutableArray<NSString *> *names = [NSMutableArray new];
    objc_property_t* plist = class_copyPropertyList(cls, &c);
    for (int i = 0; i < c; i++) {
        NSString* str = [NSString stringWithUTF8String:property_getName(plist[i])];
        [names addObject:str];
    }
    return [names copy];
}
+ (NSDictionary<NSString *,NSString *> *)propertyKeyAttributeInClass:(Class)cls{
    uint c = 0;
    NSMutableDictionary<NSString *,NSString *> *names = [NSMutableDictionary new];
    objc_property_t* plist = class_copyPropertyList(cls, &c);
    for (int i = 0; i < c; i++) {
        NSString* str = [NSString stringWithUTF8String:property_getName(plist[i])];
        NSString* value = [NSString stringWithUTF8String:property_getAttributes(plist[i])];
        names[str] = value;
    }
    return [names copy];
}
+ (NSDictionary<NSString *,NSString *> *)propertyKeyTypeInClass:(Class)cls{
    uint c = 0;
    NSMutableDictionary<NSString *,NSString *> *names = [NSMutableDictionary new];
    objc_property_t* plist = class_copyPropertyList(cls, &c);
    for (int i = 0; i < c; i++) {
        NSString* str = [NSString stringWithUTF8String:property_getName(plist[i])];
        unsigned int count = 0;
        objc_property_attribute_t * attr = property_copyAttributeList(plist[i], &count);
        for (int i = 0; i < count; i++) {
            if(*attr[i].name == 'T'){
                NSString* value = [NSString stringWithUTF8String:attr[i].value];
                names[str] = value;
                break;
            }
        }
    }
    return [names copy];
}
+ (BOOL)addMethodToClass:(Class)cls
                selector:(SEL)selector
                withType:(const char *)type
                     imp:(id)impBlock{
   return class_addMethod(cls, selector, imp_implementationWithBlock(impBlock), type);
}
+ (void)implementMethodToClass:(Class)cls
                selector:(SEL)selector
                withType:(const char *)type
                     imp:(id)impBlock{
    BOOL success = [self addMethodToClass:cls selector:selector withType:type imp:impBlock];
    if(!success){
        method_setImplementation(class_getInstanceMethod(cls, selector), imp_implementationWithBlock(impBlock));
    }
}
+ (void)classImplamentProtocol:(Protocol *)proto
                      selector:(SEL)selector
                       toClass:(Class)cls
                           imp:(id)block{
    const char * c = protocol_getMethodDescription(proto, selector, false, true).types;
    [BIOCRuntimeTool implementMethodToClass:cls selector:selector withType:c imp:block];
}
+ (NSMethodSignature *)objectMethodSignature:(Protocol *)proto sel:(SEL)selector{
    NSString * r = [self objectMethodEncode:proto sel:selector];
    if(r){
        return [NSMethodSignature signatureWithObjCTypes:r.UTF8String];
    }
    return nil;
}
+(NSString *)objectMethodEncode:(Protocol *)proto sel:(SEL)selector{
    const char * c = protocol_getMethodDescription(proto, selector, false, true).types;
    if(c != NULL){
        return [NSString stringWithUTF8String:c];
    }
    c = protocol_getMethodDescription(proto, selector, true, true).types;
    if(c != NULL){
        return [NSString stringWithUTF8String:c];
    }
    return nil;
}
+ (Class)createClass:(Class)baseClass newClass:(NSString *)newClassName{
    Class nclass = objc_allocateClassPair(baseClass, newClassName.UTF8String, 0);
    objc_registerClassPair(nclass);
    return nclass;
}
@end
