//
//  HMControllerManager.m
//  Himalaya
//
//  Created by KnowChat02 on 2019/6/21.
//

#import "HMControllerManager.h"
#import "HMAnnotation.h"
#import "HMProtocol.h"
#import "HMAnotationStorage.h"
#import <objc/runtime.h>
#import "HMOCRunTimeTool.h"
//static NSMutableDictionary *dc;
static BOOL debounce = false;


HMService(HMControllerManager,HMControllerManagerImp)
@implementation HMControllerManagerImp
@synthesize lock;
- (UIViewController *)dequeueViewController:(NSString *)name param:(NSDictionary *)param context:(nullable id)ctx{
    UIViewController * vc = [self dequeueViewControllerInner:name param:param context:ctx];
#if DEBUG
    if(vc == nil){
        UIViewController * vc = [[UIViewController alloc] init];
        UILabel* lb = [[UILabel alloc] init];
        lb.text = @"正在装修";
        lb.textAlignment = NSTextAlignmentCenter;
        lb.backgroundColor = UIColor.whiteColor;
        lb.frame = vc.view.bounds;
        lb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [vc.view addSubview:lb];
        return vc;
    }
#endif
    return vc;
}
- (UIViewController *)dequeueViewController:(NSString *)name param:(NSDictionary *)param handle:(handleControllerCallback)callback{
    return [self dequeueViewController:name param:param context:[[HMCallBack alloc] initWithCallBack:callback]];
}
- (UIViewController *)dequeueViewControllerInner:(NSString *)name param:(NSDictionary *)param context:(id)ctx{
    NSDictionary* dc = [HMAnotationStorage.shared getEnvConfigByName:@HMSectCtrlKey];
    Class cls = NSClassFromString(dc[name]);
    
    UIViewController *obj;
    id temp = [cls alloc];
    if ([temp respondsToSelector:@selector(routeVC)]){
        obj = [temp routeVC];
        return obj;
    }
    if([cls conformsToProtocol:@protocol(HMNameController)]){
        [HMOCRunTimeTool assignIVar:@{@"vcName":name} ToObject:temp];
    }
    if(temp){
        [HMModuleManager.shared assignAllModule:temp];
    }
    if([cls conformsToProtocol:@protocol(HMParamController)]){
        if ([temp respondsToSelector:@selector(canOpenViewController)]){
            if([temp canOpenViewController]){
                if(param && [temp respondsToSelector:@selector(initWithParam:)]){
                    obj = [temp initWithParam:param];
                }else{
                    if(param){
                        [HMOCRunTimeTool assignIVar:@{@"param":param} ToObject:temp];
                        
                    }
                    obj = [temp init];
                }
            }else{
                if ([temp respondsToSelector:@selector(deferViewController)]){
                    return [temp deferViewController];
                }
            }
        }else{
            if(param && [temp respondsToSelector:@selector(initWithParam:)]){
                obj = [temp initWithParam:param];
            }else{
                if(param){
                    [HMOCRunTimeTool assignIVar:@{@"param":param} ToObject:temp];
                    
                }
                obj = [temp init];
            }
        }
    }else{
        obj = [cls new];
    }
    
    if(obj == nil && dc[name] != nil){
        obj = [[UIStoryboard storyboardWithName:name bundle:[NSBundle bundleWithIdentifier:dc[name]]] instantiateInitialViewController];
        if([obj conformsToProtocol:@protocol(HMParamController)]){
            if(param){
                if([obj respondsToSelector:@selector(handleParam:)]){
                    id<HMParamController> p = (id<HMParamController>) obj;
                    [p handleParam:param];
                }else{
                    [HMOCRunTimeTool assignIVar:@{@"param":param} ToObject:temp];
                }
            }
        }
        if([obj conformsToProtocol:@protocol(HMNameController)]){
            [HMOCRunTimeTool assignIVar:@{@"vcName":name} ToObject:temp];
        }
    }else if(obj == nil){
        return nil;
    }
    if([obj conformsToProtocol:@protocol(HMRoute)]){
        HMWeakContainer* w = [[HMWeakContainer alloc] init];
        w.content = obj;
        if(!self.routers){
            self.routers = [NSMutableArray new];
        }
        [self.routers addObject:w];
    }
    if([obj conformsToProtocol:@protocol(HMManagedController)]){
        [HMOCRunTimeTool assignIVar:@{@"controllerManager":self} ToObject:obj];

        objc_setAssociatedObject(obj, @"_^&^callback", ctx, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [HMOCRunTimeTool classImplamentProtocol:@protocol(HMManagedController) selector:@selector(callbackWithName:param:) toClass:obj.class imp:^(id s,NSString *name,NSDictionary * param){
            id<HMControllerCallback> wc = objc_getAssociatedObject(s, @"_^&^callback");
            if(wc && [wc respondsToSelector:@selector(handleCallbackWithName:param:)]){
                [wc handleCallbackWithName:name param:param];
            }
        }];
    }
    [self.activeViewController addObject:obj];
    return obj;
}
+ (HMModuleMemoryType)memoryType {
    return HMModuleSinglten;
}
- (BOOL)resetRoute:(NSString *)name withParam:(NSDictionary *)param animation:(BOOL)animation callback:(handleControllerCallback)callback{
    id<HMRoute> ro = [self currentRouter];
    if(ro){
        UIViewController* vc = HMGetController(name, param, callback);
        [ro resetViewController:vc WithName:name animation:animation];
        return true;
    }
    return false;
}
- (BOOL)replaceRoute:(NSString *)name withParam:(NSDictionary *)param animation:(BOOL)animation callback:(handleControllerCallback)callback {
    while (!self.routers.lastObject.content && self.routers.count > 0) {
        [self.routers removeLastObject];
    }
    id<HMRoute> ro = [self currentRouter];
    if(ro){
        UIViewController* vc = HMGetController(name, param, callback);
        [ro replaceViewController:vc WithName:name animation:animation];
        return true;
    }
    return false;
}
- (BOOL)replaceCurrentRoute:(NSString *)name withParam:(NSDictionary *)param animation:(BOOL)animation callback:(handleControllerCallback)callback{
    while (!self.routers.lastObject.content && self.routers.count > 0) {
        [self.routers removeLastObject];
    }
    id<HMRoute> ro = [self currentRouter];
    if(ro){
        UIViewController* vc = HMGetController(name, param, callback);
    
        [ro replaceCurrentViewController:vc WithName:name animation:animation];
        return true;
    }
    return false;
}
- (BOOL)showRoute:(NSString *)name withParam:(NSDictionary *)param animation:(BOOL)animation callback:(handleControllerCallback)callback{
    if(debounce){
        return false;
    }
    debounce = true;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        debounce = false;
    });
    while (!self.routers.lastObject.content && self.routers.count > 0) {
        [self.routers removeLastObject];
    }
    id<HMRoute> ro = [self currentRouter];
    if(ro){
        UIViewController* vc = HMGetController(name, param, callback);
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
            [ro displayViewController:vc WithName:name animation:animation];
        }else{
            HMVCBackUp* b = [[HMVCBackUp alloc] init];
            b.vc = vc;
            b.name = name;
            [self.backup addObject:b];
        }
        return true;
    }
    return false;
}
- (id<HMRoute>)currentRouter{
    id<HMRoute> route;
    for (HMWeakContainer * r in self.routers) {
        if(r.content){
            if(route == nil){
                route = r.content;
            }else{
                id<HMRoute> cr = r.content;
                if([cr priority] > route.priority){
                    route = cr;
                }
            }
        }
        
    }
    return route;
}
- (BOOL)showRoutePresent:(NSString *)name
               withParam:(NSDictionary *)param
                inWindow:(nonnull UIWindow *)window
                callback:(handleControllerCallback)callback{
    return [self showRoutePresent:name withParam:param inWindow:window animation:true callback:callback];
}
- (BOOL)showRoutePresent:(NSString *)name
               withParam:(nullable NSDictionary *)param
                inWindow:(UIWindow *)window
               animation:(BOOL)animation
                callback:(nullable handleControllerCallback)callback {
    UIViewController * vc = [self dequeueViewControllerInner:name param:param context:[[HMCallBack alloc] initWithCallBack:callback]];
    if(!vc)
        return false;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController * pvc = window.rootViewController;
        while ([pvc presentedViewController]) {
            pvc = pvc.presentedViewController;
        }
        [pvc presentViewController:vc animated:animation completion:^{
        }];
    });
    return true;
}

- (void)displayViewController:(nonnull UIViewController *)vc WithName:(nonnull NSString *)name {
    
}

- (void)handleApplicationActive{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (HMVCBackUp* v in self.backup) {
            id<HMRoute> ro = (id<HMRoute>)[self currentRouter];
            [ro displayViewController:v.vc WithName:v.name animation:true];
        }
        [self.backup removeAllObjects];
    });
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.activeViewController = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
        self.backup = [NSMutableArray new];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleApplicationActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

@end


@implementation HMCallBack

- (void)handleCallbackWithName:(NSString *)name param:(NSDictionary *)param{
    if(self.callback){
        self.callback(name, param);
    }
}
- (instancetype)initWithCallBack:(handleControllerCallback)callback
{
    self = [super init];
    
    
    if (self) {
        _callback = [callback copy];
    }
    return self;
}
@synthesize controllerManager;
@end



@implementation HMVCBackUp



@end
