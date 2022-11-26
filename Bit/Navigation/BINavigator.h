//
//  Navi.h
//  Bit
//
//  Created by wenyang on 2022/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* Route;


@protocol BINavigator <NSObject>

-(void)show:(Route)route animation:(BOOL)animation param:(nullable NSDictionary*)params;

-(void)backAnimation:(BOOL)animation;

-(void)replace:(Route)route animation:(BOOL)animation param:(nullable NSDictionary*)params;

-(void)backTo:(Route)route animation:(BOOL)animation;

@end



NS_ASSUME_NONNULL_END
