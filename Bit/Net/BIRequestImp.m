//
//  BIRequest.m
//  Bit
//
//  Created by hao yin on 2022/12/5.
//

#import "BIRequestImp.h"
#import "BIModule.h"
#import "BIAnnotation.h"

@interface BIRequestImp ()<BIModule>
@property (nonatomic,nonnull) dispatch_queue_t queue;
@property (nonatomic,nonnull) NSURLSession *session;
@end

@implementation BIRequestImp

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("BIRequestImp", DISPATCH_QUEUE_CONCURRENT_WITH_AUTORELEASE_POOL);
        self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return self;
}
- (NSURL *)buildUrlWithHost:(NSString *)host
                   path:(NSString *)path
                  param:(nullable NSDictionary<NSString *,NSString *> *)param{
    NSURLComponents* c = [[NSURLComponents alloc] init];
    c.host = host;
    c.scheme = @"https";
    c.path = path;
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *key in param){
        NSString* value = param[key];
        [array addObject:[[NSURLQueryItem alloc] initWithName:key value:value]];
    }
    c.queryItems = param ? array : nil ;
    return c.URL;
}
- (NSURLRequest *) buildRequestWithUrl:(NSURL *)url
                                method:(NSString *)method
                                  body:(nullable NSData *)body{
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.requestTimeout];
    req.HTTPMethod = method;
    for (NSString* key in self.requestHeader) {
        NSString* value = self.requestHeader[key];
        [req addValue:value forHTTPHeaderField:key];
    }
    req.HTTPBody = body;
    return req;
}
- (NSURLSessionTask *)buildMethod:(NSString *)method
                               host:(NSString *)host
                               path:(NSString *)path
                              param:(nullable NSDictionary<NSString *,NSString *> *)param
                               body:(nullable NSData *)body
                           callback:(BIRequestCallback)callback{
    
    NSURL * u = [self buildUrlWithHost:host path:path param:param];
    NSURLRequest* request = [self buildRequestWithUrl:u method:method body:body];
    return [self.session dataTaskWithRequest:request completionHandler:callback];
}
+ (BIModuleMemoryType)memoryType{
    return BIModuleWeakSinglten;
}
+ (BOOL)isAsync{
    return true;
}
@synthesize requestTimeout;

@synthesize requestHeader;

- (void)requestMethod:(nonnull NSString *)method host:(nonnull NSString *)host path:(nullable NSString *)path param:(nullable NSDictionary<NSString *,NSString *> *)param body:(nullable NSData *)body callback:(nonnull BIRequestCallback)callback {
    NSURLSessionTask* task = [self buildMethod:method host:host path:path param:param body:body callback:callback];
    [task resume];
}
- (void)get:(NSString *)host path:(NSString *)path param:(NSDictionary<NSString *,NSString *> *)param callback:(BIRequestCallback)callback{
    [self requestMethod:@"GET" host:host path:path param:param body:nil callback:callback];
}
@end

BINamedService(bitRequest, BIRequest, BIRequestImp)

