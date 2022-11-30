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
    NSLog(@"%@",self.route);
    NSLog(@"%@",self.params);
    
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    BINavigationRoute* route = [BINavigationRoute route:@"/Mark/vMark" param:@{
        @"mark":@"mark"
    }];
    [self.navi present:route withAnimation:true];

}
@end


BIPathRouter(UIViewController, "/vMark", vViewController)
