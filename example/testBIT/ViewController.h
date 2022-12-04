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

@interface mkk : NSObject<mk>

@end
