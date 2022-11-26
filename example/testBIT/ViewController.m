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

@end

@interface vViewController ()
@property(nonatomic,strong) NSDate *vc;

@property(nonnull,strong)id<MarkTool> mm;

@property(nonnull,strong)UIViewController<MarkTool> *mmc;

@end
static NSString* rr;

@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIViewController* vc = [UIViewController getInstanceByName:@"/mark" params:nil];
    NSLog(@"%@",vc);
}
@end

@interface vvViewController ()<MarkTool>

@end

@implementation vvViewController



@synthesize index;

- (void)callback:(id)a ret:(void (^)(id))ret {
    
}

- (NSString *)callbackcc:(NSString *)a {
    return  @"dada";
}

- (const char *)callbackccd:(id)a {
    return  "dada";
}

- (int)callbackcd:(int)a {
    return  1;
}

- (u_long)stringLen:(const char *)a {
    return  2;
}



@end

@interface aaa ()<MarkTool>

@end

@implementation aaa



@synthesize index;

@end


BIRouter(UIViewController, MarkTool, vvViewController)

BIPathRouter(UIViewController, "/mark", vViewController)

BIService(MarkTool, aaa)
