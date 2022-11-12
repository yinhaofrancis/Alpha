//
//  H5ViewController.h
//  chufeng
//
//  Created by KnowChat02 on 2019/7/1.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMJSConfigure.h"
#import "HMProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface HMWebViewController : UIViewController<HMParamController>
@property (nonatomic,nullable) NSMutableDictionary<NSString*,id>*params;
@property (nonatomic,nonnull) WKWebView *webView;
-(instancetype)initWithConfigure:(HMJSConfigure *)configure;
-(BOOL)loadUrl:(NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
