//
//  HMWeakContainer.h
//  Himalaya
//
//  Created by KnowChat02 on 2019/6/3.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMWeakContainer : NSObject
@property (weak,nonatomic) id content;
@end

NS_ASSUME_NONNULL_END
