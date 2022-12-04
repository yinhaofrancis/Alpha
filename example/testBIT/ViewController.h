//
//  ViewController.h
//  testBIT
//
//  Created by wenyang on 2022/11/17.
//

#import <UIKit/UIKit.h>

@interface vViewController : UIViewController

@end

@protocol mk <NSObject>

- (void)make;

@end

@protocol mk2 <NSObject>

- (void)make2;

@end

@interface mkk : UIView<mk,mk2>

@end

@interface mkmk : UIColor<mk,mk2>

@end
