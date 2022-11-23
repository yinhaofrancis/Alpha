//
//  BIOCRunTimeTool.h
//  Ham
//
//  Created by KnowChat02 on 2019/10/24.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^didSetBlock)(id,void * _Nullable);

@interface BIOCRunTimeTool : NSObject

+ (void)assignIVar:(NSDictionary<NSString *,id> *)kv
          ToObject:(id)object;

+ (nullable Protocol *)createProtocolWithName:(NSString *)name
                                from:(Protocol *)protocol
                           implement:(NSDictionary<NSString *,NSString *> *)kv;


+ (void)swizzing:(SEL)originalSelector
            with:(SEL)swizzledSelector
             cls:(Class)className;

+ (void)modifyClass:(id)object cls:(NSString*)className;

+ (BOOL)addSameMethod:(SEL)selector
            encodeSel:(SEL)sameSel
              toClass:(Class)cls
                  imp:(id)impBlock;

/// 尝试添加方法
/// @param cls 类
/// @param selector selecter
/// @param type code
/// @param impBlock block
+ (BOOL)addMethodToClass:(Class)cls
                selector:(SEL)selector
                withType:(const char *)type
                     imp:(id)impBlock;
                
+(NSMethodSignature *)objectMethodSignature:(Protocol *)proto sel:(SEL)selector;

+(NSString *)objectMethodEncode:(Protocol *)proto sel:(SEL)selector;

+(NSArray<NSString *> *)propertyInClass:(Class)cls;

+(NSDictionary<NSString *,NSString *> *)propertyKeyAttributeInClass:(Class)cls;

+(NSDictionary<NSString *,NSString *> *)propertyKeyTypeInClass:(Class)cls;

/// 实现protocol
/// @param proto 协议
/// @param selector selector
/// @param cls 类
/// @param block call
+ (BOOL)classImplamentProtocol:(Protocol *)proto
                      selector:(SEL)selector
                       toClass:(Class)cls
                           imp:(id)block;


@end

#define BIAssign 0
#define BIStrong 1
#define BICopy   3

#define defineAssociatedProperty(memory,name,type)\
@property(nonatomic,nullable,getter=get##name,memory,setter=set##name:) type * name;

#define synthesizeAssociatedProperty(memory,name) \
-(id)get##name{  \
    return objc_getAssociatedObject(self, "\"____"#name"\""); \
} \
-(void)set##name:(id)v{ \
    objc_setAssociatedObject(self, "\"____"#name"\"", v, memory); \
} \

@interface NSString (OCRuntime)
@property(nonatomic,readonly) NSString* firstCapitalizedString;
@end
NS_ASSUME_NONNULL_END
