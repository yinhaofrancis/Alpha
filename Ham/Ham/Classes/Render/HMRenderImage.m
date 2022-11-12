//
//  HMRenderImage.m
//  Ham_Example
//
//  Created by hao yin on 2020/5/2.
//  Copyright © 2020 yinhaofrancis. All rights reserved.
//

#import "HMRenderImage.h"
#import "HMDrawImage.h"
#import <Metal/Metal.h>
@interface HMRenderImage()
@property (nonatomic,assign) NSInteger retainNumber;
@end
@implementation HMRenderImage{
    
    NSMutableArray<renderBlock> * _render;
    
    dispatch_queue_t _queue;
}

- (instancetype)initWithContextSize:(CGSize)size {
    self = [super init];
    if(self) {
        _contextSize = size;
        _render = [NSMutableArray new];
        _ciContext = [CIContext contextWithOptions:@{
            kCIContextPriorityRequestLow:@1,
            kCIContextUseSoftwareRenderer:@1
        }];
        dispatch_queue_attr_t aa =  dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
        _queue = dispatch_queue_create("", aa);
    }
    return self;
}

- (instancetype)init {
    return [self initWithContextSize:UIScreen.mainScreen.bounds.size];
}
- (instancetype)draw:(renderBlock)callback{
    [_render addObject:[callback copy]];
    return self;
}
- (void)drawSize:(CGSize)size callback:(getImageBlock)call {
    [self doRetain];
    dispatch_async(_queue, ^{
        CGContextFlush(self.cgContext);
        CGContextClearRect(self.cgContext, CGRectMake(0, 0, self.contextSize.width, self.contextSize.height));
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        self->_render.firstObject(self.cgContext,rect);
        CGFloat delta = self.contextSize.height * UIScreen.mainScreen.scale - rect.size.height * UIScreen.mainScreen.scale;
        CGRect exend = CGRectMake(rect.origin.x * UIScreen.mainScreen.scale,
                                  rect.origin.y * UIScreen.mainScreen.scale + delta,
                                  rect.size.width * UIScreen.mainScreen.scale,
                                  rect.size.height * UIScreen.mainScreen.scale);
        CGImageRef cimg = CGBitmapContextCreateImage(self.cgContext);
        
        CGImageRef img = CGImageCreateWithImageInRect(cimg, exend);
        CGImageRef png = CGBitMapExportPNG(img,1);
        
        UIImage * uimg =[[UIImage alloc] initWithCGImage:png scale:UIScreen.mainScreen.scale orientation:UIImageOrientationUp];
        CGImageRelease(cimg);
        CGImageRelease(png);
        call(uimg);
        [self->_render removeObjectAtIndex:0];
        [self doRelease];
    });
}
- (CIImage *)ciImage{
    return CGBitmapContextGetCIImage(_cgContext);
}
+ (instancetype)shared{
    static HMRenderImage* render;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        render = [HMRenderImage new];
    });
    return render;
}
- (void)doRetain{
    self.retainNumber += 1;
    if(self.retainNumber > 0){
        _cgContext = createContext(self.contextSize, UIScreen.mainScreen.scale, nil);
    }
}
- (void)doRelease{
    self.retainNumber -= 1;
    if(self.retainNumber <= 0){
        CGContextRelease(_cgContext);
    }
}

@end
