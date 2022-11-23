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
- (void(^)(id))callbackcc:(id)a;
@end

@interface vViewController ()<MarkTool>
@property(nonatomic,strong) NSDate *vc;

@end

@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    id<MarkTool> p = (id<MarkTool>)[[BIProxy alloc] initWithQueue:dispatch_get_global_queue(0, 0) withObject:self];

    void(^k)(id)  = [p callbackcc:@3];
    
    
    
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
- (void(^)(id))callbackcc:(id)a{
    NSLog(@"callback");
    return ^(id k){
        
    };
}
@synthesize index;

@end

BIRouter(UIViewController, MarkTool, vViewController)
