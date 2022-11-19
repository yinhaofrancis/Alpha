//
//  NSURL+BIURL.h
//  Bit
//
//  Created by wenyang on 2022/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (BIURL)
- (nullable NSDictionary<NSString *,NSString *> *)bi_param;
@end

@interface MyClass : NSObject
-(void)notActuallyAsync:(int)p1 withCompletionHandler:(void (^)(int))handler __attribute__((swift_async_error(nonnull_error)));

    

@end

NS_ASSUME_NONNULL_END
