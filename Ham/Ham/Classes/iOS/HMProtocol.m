//
//  HMProtocol.m
//  Ham
//
//  Created by hao yin on 2020/4/30.
//

#import <Foundation/Foundation.h>
#import "HMProtocol.h"
#import <Ham/Ham.h>
inline UIViewController* HMGetController(NSString * name,NSDictionary * param,handleControllerCallback callback) {
    return [InstantProtocol(HMControllerManager) dequeueViewController:name param:param handle:callback];
}


inline BOOL HMShowRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) showRoute:name withParam:param animation:true callback:callback];
}
inline BOOL HMResetRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) resetRoute:name withParam:param animation:true callback:callback];
}

inline BOOL HMShowRouteNoAnimation(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) showRoute:name withParam:param animation:false callback:callback];
}
inline BOOL HMReplaceRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) replaceRoute:name  withParam:param animation:true callback:callback];
}

inline BOOL HMReplaceCurrentRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) replaceCurrentRoute:name  withParam:param animation:true callback:callback];
}

inline UIViewController* HMGetControllerWithContext(NSString * name,NSDictionary  * _Nullable  param,id<HMControllerCallback> context){
    return [InstantProtocol(HMControllerManager) dequeueViewController:name param:param context:context];
}

inline BOOL HMShowRoutePresent(NSString * name,NSDictionary  * _Nullable  param,UIWindow* window ,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) showRoutePresent:name withParam:param inWindow:window callback:callback];
}
inline BOOL HMShowRoutePresentNoAnimation(NSString * name,NSDictionary  * _Nullable  param,UIWindow* window ,handleControllerCallback _Nullable callback){
    return [InstantProtocol(HMControllerManager) showRoutePresent:name withParam:param inWindow:window animation:false callback:callback];
}
inline BOOL HMShowRoutePresentMainWindow(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback) {
    return [InstantProtocol(HMControllerManager) showRoutePresent:name withParam:param inWindow:UIApplication.sharedApplication.windows.firstObject callback:callback];
}
inline BOOL HMShowRoutePresentMainWindowNoAnimation(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback) {
    return [InstantProtocol(HMControllerManager) showRoutePresent:name withParam:param inWindow:UIApplication.sharedApplication.windows.firstObject animation:false callback:callback];
}
