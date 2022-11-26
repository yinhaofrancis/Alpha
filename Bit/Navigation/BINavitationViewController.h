//
//  BINavitationViewController.h
//  Bit
//
//  Created by wenyang on 2022/11/26.
//

#import <UIKit/UIKit.h>

#import "BINavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface BINavitationViewController : UINavigationController

@end

@interface UIViewController (BINavitationViewController)
@property (nonatomic,copy) Route route;
@end

NS_ASSUME_NONNULL_END
