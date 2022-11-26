//
//  BINavigationImp.m
//  Bit
//
//  Created by wenyang on 2022/11/27.
//
#import "BINavigator.h"
#import "BINavigationImp.h"
#import "BIAnnotation.h"
@interface BINavigationImp()<BINavigator>

@end
@implementation BINavigationImp

- (void)backAnimation:(BOOL)animation {
    
}

- (void)backTo:(nonnull Route)route animation:(BOOL)animation {
    
}

- (void)present:(nonnull Route)route animation:(BOOL)animation {
    
}

- (void)replace:(nonnull Route)route animation:(BOOL)animation param:(nullable NSDictionary *)params {
    
}

- (void)show:(nonnull Route)route animation:(BOOL)animation param:(nullable NSDictionary *)params {
    
}

@end

BIService(BINavigator, BINavigationImp)

