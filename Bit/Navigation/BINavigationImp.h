//
//  BINavigationImp.h
//  Bit
//
//  Created by hao yin on 2022/11/29.
//

#import <Foundation/Foundation.h>

#import "BINavigation.h"
#import "BIWeakContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BINavigationImp : NSObject<BINavigation>
@property(nonatomic,strong) NSMutableArray<BIWeakContainer<id<BINavigator>> *> *stacks;
@end

NS_ASSUME_NONNULL_END
