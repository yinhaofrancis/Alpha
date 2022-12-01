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

@property (nonatomic,weak) id<BINavigation> navi;
@end


@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithWhite:(arc4random() % 255) / 255.0 alpha:1];
    NSLog(@"%@",self.bi_route);
    NSLog(@"%@",self.bi_params);
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navi present:[BINavigationRoute url:[NSURL URLWithString:@"/Mark/vMark?mark=mark"]] withAnimation:true];
}
@end


BIPathRouter(UIViewController, "/vMark", vViewController)
