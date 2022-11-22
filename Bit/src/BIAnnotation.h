//
//  BIAnnotation.h
//   
//
//  Created by KnowChat02 on 2019/6/3.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef BISectModuleName

#define BISectModuleName "BISectModuleName"

#endif

#ifndef BISectCustom

#define BISectCustom "BISectCustom"

#endif

#ifndef Annotation

#define BIDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

#define BIModule(name,cls) \
@class cls; \
char const * BI##name##_mod BIDATA(BISectModuleName) =  "{ \""#name"\" : \""#cls"\"}";

#define BIService(proto,cls) \
@protocol proto; \
char const * BI##proto##_ser##cls##end BIDATA(BISectModuleName) =  "{ \""#proto"\" : \""#cls"\"}";

#define BICustomAnnotation(owner,key,value) \
@class BIAnnotation; \
char const * BI##owner##_##key##_##value##_contr_Annotation BIDATA(BISectCustom) =  "{\""#owner"\":{ \""#key"\" : \""#value"\"}}";

#define BICustomAnnotationString(owner,key,value) \
@class BIAnnotation; \
char const * BI##owner##_##key##_contr_Annotation BIDATA(BISectCustom) =  "{\""#owner"\":{ \""#key"\" :\"" value"\"}}";


#define BIRouter(baseClass,proto,cls) \
BICustomAnnotation(baseClass,proto,cls)

#define BIPathRouter(baseClass,path,cls) \
BICustomAnnotationString(baseClass,path,cls)

#define BIInstantProtocol(protocol) \
(id<protocol>)[BIModuleManager.shared getInstanceByName:[NSString stringWithUTF8String:""#protocol""]]\

#define BIInstantProtocolWithClass(proto,cls) \
(cls<proto> *)[BIModuleManager.shared getInstanceByProtocol:@protocol(proto) baseClass:[cls class]]\


#define BIConfigure(level) \
@class BIAnnotation;   \
__attribute__((constructor(1001 + level)))
#endif

NS_ASSUME_NONNULL_BEGIN
@interface BIAnnotation : NSObject

@end

NS_ASSUME_NONNULL_END
