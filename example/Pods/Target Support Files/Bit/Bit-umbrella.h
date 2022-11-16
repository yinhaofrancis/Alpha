#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BIAnnotation.h"
#import "BIAnotationStorage.h"
#import "BIModule.h"
#import "BIModuleManager.h"
#import "BIOCRunTimeTool.h"
#import "BIProxy.h"
#import "BIWeakContainer.h"
#import "NSURL+BIURL.h"

FOUNDATION_EXPORT double BitVersionNumber;
FOUNDATION_EXPORT const unsigned char BitVersionString[];
