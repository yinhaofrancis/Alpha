//
//  ViewController.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import "ViewController.h"
@import Bit;
#import <mach-o/loader.h>



@interface vViewController ()

@property (nonatomic,strong) id<BINavigation> navi;

@property (nonatomic,strong) id<mk> mm;

@property (nonatomic,strong) id<mk> mkm;

@end


@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithWhite:(arc4random() % 255) / 255.0 alpha:1];
    NSLog(@"%@",self.bi_route);
    NSLog(@"%@",self.bi_params);
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    id a = [BIM() getInstanceByProtocol:@protocol(mk) withName:@"mm"];
    
    NSLog(@"%@",a);
    [self.navi present:[BINavigationRoute url:[NSURL URLWithString:@"/Mark/vMark?mark=mark"]] withAnimation:true];
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
