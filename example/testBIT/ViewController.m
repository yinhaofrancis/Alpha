//
//  ViewController.m
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import "ViewController.h"
@import Bit;


@protocol MarkTool <NSObject>

@property(nonatomic,assign) NSInteger index;
@optional
- (NSString *)callbackcc:(id)a;
@end

@interface vViewController ()<MarkTool>
@property(nonatomic,strong) NSDate *vc;

@end

@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BIInvocationProxy* a = [[BIInvocationProxy alloc] initWithProtocol:@protocol(MarkTool)];
    [a implement:@selector(callbackcc:) methodBlock:^(NSInvocation * _Nonnull inv) {
        NSLog(@"%@",inv);
        [inv setReturnValue:@"aa"];
    }];
    NSString *ap = [a performSelector:@selector(callbackcc:) withObject:^(id c){
        NSLog(@"%@",c);
    }];
    NSLog(@"%s",ap.UTF8String);
    // Do any additional setup after loading the view.
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
