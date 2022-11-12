//
//  H5ViewController.m
//  chufeng
//
//  Created by KnowChat02 on 2019/7/1.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "HMWebViewController.h"

@interface HMWebViewController ()
@property (nonatomic,nonnull)HMJSConfigure *configure;
@end

@implementation HMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    NSArray *array = @[
                       [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                       [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                       [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                       [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]];
    [self.view addConstraints:array];
}
-(instancetype)initWithConfigure:(HMJSConfigure *)configure{
    self = [super init];
    if (self) {
        self.webView = [[WKWebView alloc] initWithFrame:UIScreen.mainScreen.bounds configuration:configure.configure];
        _configure = configure;
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (BOOL)loadUrl:(NSString *)urlStr{
    NSURL* url = [NSURL URLWithString:urlStr];
    if(!url.scheme){
        urlStr = [@"https://" stringByAppendingString:urlStr];
        url = [NSURL URLWithString:urlStr];
        if(!url){
            return false;
        }
    }
    [self.webView loadRequest: [NSURLRequest requestWithURL:url]];
    return true;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        if([keyPath isEqualToString:@"title"]){
            self.navigationItem.title = change[NSKeyValueChangeNewKey];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (BOOL)showNavigationBar{
    return true;
}
- (BOOL)needSysPanback{
    return false;
}
- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"title"];
}
@synthesize param;

@end
