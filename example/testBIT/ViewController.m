//
//  ViewController.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import "ViewController.h"
@import Bit;
#import <mach-o/loader.h>

@protocol MarkTool <NSObject>

@property(nonatomic,assign) NSInteger index;
@optional
- (NSString *)callbackcc:(id)a;
@end

@interface vViewController ()<MarkTool>
@property(nonatomic,strong) NSDate *vc;

@end
static NSString* rr;

@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BIWrap<UIView *> *p = [[BIWrap<UIView *> alloc] initWithObject:[UIView new]];
    [self.view addSubview:p.object];
    p.object.frame = CGRectMake(10, 10, 100, 100);
    p.object.backgroundColor = UIColor.redColor;
    dyldPath();
}
- (id)callback:(id)a{
    NSLog(@"callback");
    for (int i = 0; i < 10; i++){
        sleep(1);
    }
    
    return @(1);
}
- (void)callback:(id)a ret:(void(^)(id))ret{
    NSLog(@"callback");
}

@synthesize index;

@end





BIRouter(UIViewController, MarkTool, vViewController)
