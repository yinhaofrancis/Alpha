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

@end

@interface vViewController ()<MarkTool>
@property(nonatomic,strong) UIViewController<MarkTool> *vc;

@end

@implementation vViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.vc == nil){
            UIViewController<MarkTool> *mark = BIInstantProtocolWithClass(MarkTool, UIViewController);
            mark.index = self.index + 1;
            [self presentViewController:mark animated:true completion:nil];
        }
    });
    NSLog(@"index = %@",@(self.index));
    
    // Do any additional setup after loading the view.
}

@synthesize index;

@end

BIRouter(UIViewController, MarkTool, vViewController)
