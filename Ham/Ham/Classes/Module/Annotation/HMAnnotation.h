//
//  HMAnnotation.h
//  Himalaya
//
//  Created by KnowChat02 on 2019/6/3.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMModuleManager.h"
#ifndef HMSectModuleName

#define HMSectModuleName "HMSectModuleName"

#endif

#ifndef HMSectCustom

#define HMSectCustom "HMSectCustom"

#endif

#ifndef Annotation

#define HMDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

#define HMModule(name,cls) \
@class cls; \
char const * HM##name##_mod HMDATA(HMSectModuleName) =  "{ \""#name"\" : \""#cls"\"}";

#define HMKeyModule(index,name,cls) \
@class cls; \
char const * HM##index##_mod_##cls##ddd HMDATA(HMSectModuleName) =  "{ \"" name"\" : \""#cls"\"}";

#define HMClass(cls) \
HMModule(cls,cls)

#define HMService(proto,cls) \
@protocol proto; \
char const * HM##proto##_ser##cls##end HMDATA(HMSectModuleName) =  "{ \""#proto"\" : \""#cls"\"}";

#define HMCustomAnnotation(owner,key,value) \
@class HMAnnotation; \
char const * HM##owner##_##key##_##value##_contr_Annotation HMDATA(HMSectCustom) =  "{\""#owner"\":{ \""#key"\" : \""#value"\"}}";

#define HMCustomAnnotationString(owner,key,value) \
@class HMAnnotation; \
char const * HM##owner##_##key##_contr_Annotation HMDATA(HMSectCustom) =  "{\""#owner"\":{ \""#key"\" :\"" value"\"}}";

#define InstantProtocol(protocol) \
(id<protocol>)[HMModuleManager.shared getInstanceByName:[NSString stringWithUTF8String:""#protocol""]]\

#define instantWithName(cls,name) \
(cls *)[HMModuleManager.shared getInstanceByName:[NSString stringWithUTF8String:""#name""]]\

#define instant(cls) \
(cls *)[HMModuleManager.shared getInstanceByName:[NSString stringWithUTF8String:""#cls""]]\

#define InstantClassProtocol(protocol) \
[HMModuleManager.shared getInstanceClassByName:[NSString stringWithUTF8String:""#protocol""]]\

#define instantClass(name) \
[HMModuleManager.shared getInstanceClassByName:[NSString stringWithUTF8String:""#name""]]\


#define Configure(level) \
@class HMAnnotation;   \
__attribute__((constructor(1001 + level)))
#endif


NS_ASSUME_NONNULL_BEGIN
@interface HMAnnotation : NSObject

@end

NS_ASSUME_NONNULL_END
