//
//  BIWeakContainer.m
//   
//
//  Created by KnowChat02 on 2019/6/3.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "BIWeakContainer.h"

@implementation BIWeakContainer
- (instancetype)initWithContent:(NSObject *)content{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}
@end
