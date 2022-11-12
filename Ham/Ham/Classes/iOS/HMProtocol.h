//
//  HMProtocol.h
//  Himalaya
//
//  Created by KnowChat02 on 2019/6/21.
//

#import <UIKit/UIKit.h>
#import "HMModule.h"

#define HMSectCtrlKey "HMSectCtrl"

#define HMController(router,controller) \
@class controller; \
HMCustomAnnotation(HMSectCtrl,router,controller)


#define HMKeyController(router,controller) \
@class controller; \
char const * HMConr_##controller##_contr_Annotation HMDATA(HMSectCustom) =  "{\"HMSectCtrl\":{ \"" router"\" :\""#controller"\"}}";



#define HMNextKeyController(key,router,controller) \
@class controller; \
char const * HMConr_##controller##_contr##key##_Annotation HMDATA(HMSectCustom) =  "{\"HMSectCtrl\":{ \"" router"\" :\""#controller"\"}}";

#define HMNibController(router,bundleId) \
HMCustomAnnotationString(HMSectCtrl,router,bundleId)

NS_ASSUME_NONNULL_BEGIN



typedef void(^handleControllerCallback)(NSString * name,NSDictionary *param);
@protocol HMControllerCallback;


UIViewController* HMGetController(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);

UIViewController* HMGetControllerWithContext(NSString * name,NSDictionary  * _Nullable  param,id<HMControllerCallback> context);

BOOL HMShowRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);

BOOL HMShowRouteNoAnimation(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);

BOOL HMReplaceRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);

BOOL HMReplaceCurrentRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);
BOOL HMResetRoute(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);
BOOL HMBackRoute(void);

BOOL HMShowRoutePresent(NSString * name,NSDictionary  * _Nullable  param,UIWindow * window,handleControllerCallback _Nullable callback);
BOOL HMShowRoutePresentNoAnimation(NSString * name,NSDictionary  * _Nullable  param,UIWindow* window ,handleControllerCallback _Nullable callback);

BOOL HMShowRoutePresentMainWindow(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);
BOOL HMShowRoutePresentMainWindowNoAnimation(NSString * name,NSDictionary  * _Nullable  param,handleControllerCallback _Nullable callback);
@protocol HMRoute <NSObject>

- (void) displayViewController:(UIViewController *)vc WithName:(NSString *)name animation:(BOOL)animation;

- (void) replaceViewController:(UIViewController *)vc WithName:(NSString *)name animation:(BOOL)animation;

- (void) replaceCurrentViewController:(UIViewController *)vc WithName:(NSString *)name animation:(BOOL)animation;

- (void)resetViewController:(UIViewController *)vc WithName:(NSString *)name animation:(BOOL)animation;

- (NSInteger)priority;

@end
@protocol HMControllerManager <NSObject>

- (UIViewController *)dequeueViewController:(NSString *)name param:(nullable NSDictionary *)param context:(nullable id)ctx;

- (UIViewController *)dequeueViewController:(NSString *)name param:(nullable NSDictionary *)param handle:(nullable handleControllerCallback)callback;
- (BOOL)showRoute:(NSString *)name
        withParam:(nullable NSDictionary *)param
        animation:(BOOL)animation
         callback:(nullable handleControllerCallback)callback;

- (BOOL)resetRoute:(NSString *)name
        withParam:(nullable NSDictionary *)param
        animation:(BOOL)animation
         callback:(nullable handleControllerCallback)callback;
- (BOOL)replaceRoute:(NSString *)name
        withParam:(nullable NSDictionary *)param
           animation:(BOOL)animation
         callback:(nullable handleControllerCallback)callback;

- (BOOL)replaceCurrentRoute:(NSString *)name
        withParam:(nullable NSDictionary *)param
           animation:(BOOL)animation
         callback:(nullable handleControllerCallback)callback;

- (BOOL)showRoutePresent:(NSString *)name
               withParam:(nullable NSDictionary *)param
                inWindow:(UIWindow *)window
                callback:(nullable handleControllerCallback)callback;
- (BOOL)showRoutePresent:(NSString *)name
               withParam:(nullable NSDictionary *)param
                inWindow:(UIWindow *)window
               animation:(BOOL)animation
                callback:(nullable handleControllerCallback)callback;
@property(nonatomic,readonly) id<HMRoute> currentRouter;
@property(nonatomic,assign) BOOL lock;
@end



@protocol HMControllerCallback <NSObject>
@optional
- (void) handleCallbackWithName:(NSString *)name param:(nullable NSDictionary*)param;
@end


@protocol HMManagedController <HMControllerCallback>

@property (nonatomic,weak)id<HMControllerManager> controllerManager;

@optional

- (void) callbackWithName:(NSString *)name param:(nullable NSDictionary*)param;



@end


@protocol HMParamController <NSObject>
@property (nonatomic,readonly) NSDictionary *param;
@optional
- (instancetype)initWithParam:(nullable NSDictionary *)param;
- (void)handleParam:(NSDictionary *)param;
- (BOOL)canOpenViewController;
- (UIViewController *)deferViewController;
@end

@protocol HMNameController <NSObject>
@property (nonatomic,readonly) NSString* vcName;

@end




@protocol HMResourceLoader <NSObject>

-(void)loadResource:(NSURL *)url handle:(void(^)(NSData * data))handle;

-(NSURL *)loadLocalUrl:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
