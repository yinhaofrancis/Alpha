//
//  HMControllerManager.h
//  Himalaya
//
//  Created by KnowChat02 on 2019/6/21.
//

#import <Foundation/Foundation.h>
#import "HMModule.h"
#import "HMProtocol.h"
#import "HMWeakContainer.h"

NS_ASSUME_NONNULL_BEGIN
@interface HMCallBack : NSObject<HMManagedController>
@property (nonatomic,readonly) handleControllerCallback callback;
- (instancetype)initWithCallBack:(handleControllerCallback)callback;
@end
@interface HMVCBackUp : NSObject
@property(nonatomic,strong) UIViewController* vc;
@property(nonatomic,copy) NSString *name;

@end

@protocol HMVCFactory <NSObject>
- (UIViewController *)routeVC;
@end
@interface HMControllerManagerImp : NSObject<HMModule,HMControllerManager>
@property (nonatomic,strong) NSMutableArray<HMWeakContainer *> *routers;
@property (nonatomic,strong) NSHashTable *activeViewController;
@property (nonatomic,strong) NSMutableArray<HMVCBackUp *> *backup;

@end

NS_ASSUME_NONNULL_END
