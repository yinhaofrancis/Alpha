//
//  BINavigationRoute.h
//  Bit
//
//  Created by hao yin on 2022/11/30.
//

#import <Foundation/Foundation.h>

#import "BIModuleManager.h"

NS_ASSUME_NONNULL_BEGIN



@interface BINavigationRoute : NSString

@property(nonatomic,readonly) Route route;

@property(nonatomic,readonly) NSDictionary *param;

@property(nonatomic,readonly) BINavigationRoute* next;

- (void)bindParam:(NSString *)key value:(id)value;

- (instancetype)initWithRoute:(Route)route;

- (instancetype)initWithRoute:(Route)route next:(nullable BINavigationRoute *)next;

- (instancetype)initWithRoute:(Route)route param:(nullable NSDictionary*)param next:(nullable BINavigationRoute *)next;

+ (instancetype)route:(Route)route param:(nullable NSDictionary*)param;

+ (instancetype)url:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
