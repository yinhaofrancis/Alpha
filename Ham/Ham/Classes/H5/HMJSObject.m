//
//  HMJSObject.m
//  chufeng
//
//  Created by KnowChat02 on 2019/7/1.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "HMJSObject.h"

@implementation HMJSObject
@synthesize functionName = _functionName;
- (instancetype)initWithNaiveFuntionName:(NSString *)name callback:(NaiveFunction)function {
    self = [super init];
    if (self) {
        _functionName = name;
        _naiveFuncCallBack = function;
    }
    return self;
}
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if(_naiveFuncCallBack){
        __weak HMJSObject *m = self;
        _naiveFuncCallBack(userContentController,message,^(id  _Nullable a, NSString * _Nullable b) {
            [m oldCallJS:a error:b message:message];
        });
        
    }
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message replyHandler:(void (^)(id _Nullable, NSString * _Nullable))replyHandler{
    __weak HMJSObject *m = self;
    self.naiveFuncCallBack(userContentController, message, ^(id  _Nullable a, NSString * _Nullable b) {
        [m oldCallJS:a error:b message:message];
        replyHandler(a,b);
    });
}
-(void)oldCallJS:(id)object error:(NSString*)e message:(WKScriptMessage *)message{
    NSString* appjs = [[NSString stringWithFormat:@"App.%@(",message.name] stringByAppendingFormat:@"%@)",object];
    [message.webView evaluateJavaScript: appjs completionHandler:nil];
}
@end

