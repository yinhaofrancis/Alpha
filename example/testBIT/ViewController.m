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
    id ret;
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test1:" params:@1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test2:" params:@-1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test3:" params:@-1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test4:" params:@1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test5:" params:@-1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test6:" params:@1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test7:" params:@-1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Test8:" params:@1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Testf:" params:@1.1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Testd:" params:@1.1, nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Teststr:" params:@"str化的", nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Testcc:" params:@"str化的", nil];
    NSLog(@"%@",ret);
    ret = [BIM() performTarget:@"mm_mk" selector:@"Testnum:" params:@122, nil];
    NSLog(@"%@",ret);
}
@end

@implementation mkk

- (void)make{
    NSLog(@"!!!!%@",self);
}

- (void)make2 {
    NSLog(@"!!!!%@!!",self);
}
-(NSString*)Teststr:(NSString*)i{
    NSAssert([i isEqualToString:@"str化的"],@"fail");
    return i;
}
-(const char *)Testcc:(const char *)i{
    NSAssert(strcmp(i, "str化的") == 0,@"fail");
    return i;
}
-(uint8_t)Test1:(uint8_t)i{
    NSAssert(i == 1,@"fail");
    return i;
}
-(int8_t)Test2:(int8_t)i{
    NSAssert(i == -1,@"fail");
    return i;
}
-(int16_t)Test3:(int16_t)i{
    NSAssert(i == -1,@"fail");
    return i;
}
-(uint16_t)Test4:(uint16_t)i{
    NSAssert(i == 1,@"fail");
    return i;
}
-(int32_t)Test5:(int32_t)i{
    NSAssert(i == -1,@"fail");
    return i;
}
-(uint32_t)Test6:(uint32_t)i{
    NSAssert(i == 1,@"fail");
    return i;
}
-(int64_t)Test7:(int64_t)i{
    NSAssert(i == -1,@"fail");
    return i;
}
-(uint64_t)Test8:(uint64_t)i{
    NSAssert(i == 1,@"fail");
    return i;
}
-(float)Testf:(float)i{
    NSAssert(i - 1.1 < 0.00001,@"fail");
    return i;
}
-(double)Testd:(double)i{
    NSAssert(i - 1.1 < 0.00001,@"fail");
    return i;
}

-(NSNumber *)Testnum:(NSNumber *)i{
    NSAssert(i.doubleValue - 122 < 0.00001,@"fail");
    return i;
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
