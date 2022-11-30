//
//  BINavigationRoute.m
//  Bit
//
//  Created by hao yin on 2022/11/30.
//

#import "BINavigationRoute.h"

@implementation BINavigationRoute{
    NSMutableDictionary* _param;
}
- (void)bindParam:(NSString *)key value:(id)value{
    if(_param == nil){
        _param = [NSMutableDictionary new];
    }
    _param[key] = value;
}
- (NSDictionary *)param{
    return [_param copy];
}

- (instancetype)initWithRoute:(Route)route {
    return [self initWithRoute:route param:nil next:nil];
}

- (instancetype)initWithRoute:(Route)route next:(BINavigationRoute *)next {
    return [self initWithRoute:route param:nil next:next];
}

- (instancetype)initWithRoute:(Route)route param:(nullable NSDictionary*)param next:(nullable BINavigationRoute *)next{
    self = [super init];
    if (self) {
        _route = route;
        _next = next;
        _param = [_param mutableCopy];
    }
    return self;
}

@end
