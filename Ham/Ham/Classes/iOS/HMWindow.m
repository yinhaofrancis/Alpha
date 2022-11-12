//
//  FRWindow.m
//  chufeng
//
//  Created by KnowChat02 on 2019/5/15.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "HMWindow.h"
#import "HMWindowManager.h"
@implementation HMWindow
- (void)visiableSelfComplete:(void (^)(BOOL))handle{
    self.hidden = false;
    if([self.animation respondsToSelector:@selector(showAnimation:complete:)]){
        [self.animation showAnimation:self complete:handle];
    }else{
        handle(true);
    }
}
- (void)removeSelfComplete:(void (^)(BOOL))handle {
    if([self.animation respondsToSelector:@selector(hideAnimation:complete:)]){
        [self.animation hideAnimation:self complete:handle];
    }else{
        handle(true);
        self.hidden = true;
    }
}
- (void)dealloc
{
    
}
@end
