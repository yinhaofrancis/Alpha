//
//  BIRequest.h
//  Bit
//
//  Created by hao yin on 2022/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BIRequestCallback)(id _Nullable, NSURLResponse * _Nullable, NSError * _Nullable);


@protocol BIRequest <NSObject>

@property(assign,nonatomic) NSTimeInterval requestTimeout;

@property(copy,nonatomic) NSDictionary<NSString *,NSString *> *requestHeader;

- (void)requestMethod:(NSString *)method host:(NSString *)host path:(nullable NSString *)path param:(nullable NSDictionary<NSString *,NSString *> *)param body:(nullable NSData *)body callback:(BIRequestCallback)callback;
- (void)get:(NSString *)host path:(nullable NSString *)path param:(nullable NSDictionary<NSString *,NSString *> *)param callback:(BIRequestCallback)callback;
@end

NS_ASSUME_NONNULL_END
