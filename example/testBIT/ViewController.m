//
//  ViewController.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//
#import <sys/signal.h>
#import "ViewController.h"
@import Bit;
#import <mach-o/loader.h>



@interface vViewController ()

@property (nonatomic,strong) id<BIRequest> bitRequest;

@end


@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithWhite:(arc4random() % 255) / 255.0 alpha:1];
    NSLog(@"%@",self.bi_route);
    NSLog(@"%@",self.bi_params);
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.bitRequest get:@"www.json.cn" path:@"/json/json2csharp.html" param:nil callback:^(id data, NSURLResponse * _Nullable response, NSError * _Nullable e) {
        NSLog(@"%@",response);
    }];
}
@end

@implementation mkk

- (void)make{
    NSLog(@"!!!!%@",self);
}

- (void)make2 {
    NSLog(@"!!!!%@!!",self);
}

@end

@implementation mkmk

- (void)make{
    NSLog(@"!!!!%@",self);
}

- (void)make2 {
    NSLog(@"!!!!%@!!",self);
}

@end
BIPathRouter(UIViewController, "/vMark", vViewController)

BIRouter(UIView, mk, mkk)
BIRouter(UIView, mk2, mkk)

BINamedService(mm, mk, mkk)

BINamedService(mkm, mk, mkmk)
