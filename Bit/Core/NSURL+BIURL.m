//
//  NSURL+BIURL.m
//  Bit
//
//  Created by wenyang on 2022/11/16.
//

#import "NSURL+BIURL.h"

@implementation NSURL (BIURL)
- (NSDictionary<NSString *,NSString *> *)bi_param{
    NSURLComponents* c = [[NSURLComponents alloc] initWithString:self.absoluteString];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    for (NSURLQueryItem *item in c.queryItems) {
        dic[item.name] = item.value;
    }
    return [dic copy];
}
@end
