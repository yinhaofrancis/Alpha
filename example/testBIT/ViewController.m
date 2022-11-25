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
- (NSString *)callbackcc:(NSString *)a;
- (const char *)callbackccd:(id)a;
- (void)callback:(id)a ret:(void(^)(id))ret;
- (int)callbackcd:(int)a;
- (u_long)stringLen:(const char *)a;
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
    NSString* s = [BIM() performTarget:@"MarkTool" baseClass:UIViewController.class selector:@"callbackcc:" params:@"123", nil];
    NSString* s1 = [BIM() performTarget:@"MarkTool" baseClass:UIViewController.class selector:@"callbackccd:" param:@[@"123"]];
    NSString* s2 = [BIM() performTarget:@"MarkTool" baseClass:UIViewController.class selector:@"callbackcd:" param:@[@(123)]];
    NSString* s3 = [BIM() performTarget:@"MarkTool" baseClass:UIViewController.class selector:@"callback:ret:" param:@[@{@"dd":@"ddd"},^void(id a){
        NSLog(@"%@",a);
    }]];
    NSString* s4 = [BIM() performTarget:@"MarkTool" baseClass:UIViewController.class selector:@"stringLen:" param:@[@"123"]];
    @try {
        [BIM() performTarget:@"MarkTool" baseClass:UIViewController.class selector:@"stringLeeen:" param:@[@"123"]];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        NSLog(@"%@，%@，%@，%@,%@",s,s1,s2,s3,s4);
    }
    
    
    
}
- (id)callback:(id)a{
    NSLog(@"callback");
    for (int i = 0; i < 10; i++){
        sleep(1);
    }
    
    return @(1);
}
- (void)callback:(id)a ret:(void(^)(id))ret{
    if(a == nil){
        ret(@"nil callback");
    }else{
        ret(@"callback");
    }
    
}


- (const char *)callbackccd:(id)a {
    return  "1234";
}


- (int)callbackcd:(int)a {
    return a;
}

- (NSString *)callbackcc:(NSString *)a {
    return a;
}

- (u_long)stringLen:(const char *)a {
    return strlen(a);
}




@synthesize index;

@end





BIRouter(UIViewController, MarkTool, vViewController)
