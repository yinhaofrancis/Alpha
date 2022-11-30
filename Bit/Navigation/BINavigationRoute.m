//
//  BINavigationRoute.m
//  Bit
//
//  Created by hao yin on 2022/11/30.
//

#import "BINavigationRoute.h"
#import "NSURL+BIURL.h"

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
        _param = [param mutableCopy];
    }
    return self;
}

+ (instancetype)route:(Route)route param:(nullable NSDictionary*)param{
    NSMutableArray* a = [NSMutableArray new];
    [[route componentsSeparatedByString:@"/"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(obj.length > 0){
            [a addObject:[NSString stringWithFormat:@"/%@",obj]];
        }
    }];
    NSEnumerator<NSString *>* e = a.reverseObjectEnumerator;
    NSString* routeItem;
    BINavigationRoute *current;
    while ((routeItem = e.nextObject)) {
        current = [[BINavigationRoute alloc] initWithRoute:routeItem param:param next:current];
    }
    return current;
}
+ (instancetype)url:(NSURL *)url{
    return [self route:url.path param:url.bi_param];
}

@end
