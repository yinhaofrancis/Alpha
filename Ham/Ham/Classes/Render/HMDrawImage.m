//
//  HMDrawImage.m
//  Himalaya
//
//  Created by KnowChat02 on 2019/5/30.
//  Copyright © 2019 KnowChat02. All rights reserved.
//

#import "HMDrawImage.h"
#import <MobileCoreServices/MobileCoreServices.h>
@implementation HMDrawImage{
    CGSize size;
    DrawCallBlock drawCallBlock;
    void* buffer;
    CGContextRef ctx;
    NSData * _pixelData;
}
- (instancetype)initWithBitmapBuffer:(void *)buffer Size:(CGSize)size ForCallback:(DrawCallBlock)call{
    self = [super init];
    if (self) {
        self->size = size;
        drawCallBlock = call;
        _isPNG = false;
        self->buffer = buffer;
        
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size ForCallback:(DrawCallBlock)call {
    return [self initWithSize:size isPNG:false ForCallback:call];
}
- (instancetype)initWithSize:(CGSize)size isPNG:(BOOL)flag ForCallback:(DrawCallBlock)call{
    self = [super init];
    if (self) {
        self->size = size;
        drawCallBlock = call;
        _isPNG = flag;
    }
    return self;
}


- (UIImage *)synchronization{
    CGImageRef img = [self synchronizationGC];
    
    UIImage* ximg = [[UIImage alloc] initWithCGImage:img scale:UIScreen.mainScreen.scale orientation:UIImageOrientationUp];
    CGImageRelease(img);
    return ximg;
}
- (CGImageRef)synchronizationGC{
    if(!ctx){
        CGContextRef ctx = [self makeContext];
        self->ctx = ctx;
    }
    drawCallBlock(ctx,self);
    CGImageRef img = [self cgImage];
    return img;
}
- (void)asynchronization:(void(^)(UIImage * _Nullable))callback{
    dispatch_queue_t q = dispatch_queue_create("draw", nil);
    dispatch_async(q, ^{
        UIImage * img = [self synchronization];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(img);
        });
    });
}
- (void)render{
    if(!self.ctx) {
        CGContextRef ctx = [self makeContext];
        self->ctx = ctx;
    }
    drawCallBlock(ctx,self);
}

- (CGContextRef) makeContext{
    if (self.hasAlpha){
        return createContext(size, UIScreen.mainScreen.scale,nil);
    }else{
        return createContextNoAlpha(size,UIScreen.mainScreen.scale, UIColor.whiteColor.CGColor, nil);
    }
}
- (CGSize)contextSize{
    return size;
}
- (CGContextRef)ctx{
    return self->ctx;
}
-(void)setHasAlpha:(BOOL)hasAlpha{
    _hasAlpha = hasAlpha;
    CGContextRelease(ctx);
    ctx = [self makeContext];
}
-(void)setIsPNG:(BOOL)isPNG{
    _isPNG = isPNG;
}
- (CIImage *)ciImage {
    if(!ctx){
        self->ctx = [self makeContext];
    }
    CGSize size = CGSizeMake(CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    return [[CIImage alloc] initWithBitmapData:self.pixelData bytesPerRow:CGBitmapContextGetBytesPerRow(ctx) size:size format:kCIFormatRGBA8 colorSpace:CGBitmapContextGetColorSpace(ctx)];
}
- (UIImage *)uiImage{
    CGImageRef img = [self cgImage];
    
    UIImage *Iimg = [[UIImage alloc] initWithCGImage:img];
    
    CGImageRelease(img);
    
    return Iimg;
}


- (CGImageRef)cgImage {
    return self.isPNG ? CGBitContextExportPNG(ctx, 1) :CGBitContextExportJPG(ctx, 1);
}

- (NSData *)pixelData{
    if(!_pixelData) {
        _pixelData = [[NSData alloc] initWithBytesNoCopy:CGBitmapContextGetData(ctx) length:CGBitmapContextGetBytesPerRow(ctx) * CGBitmapContextGetHeight(ctx)];
    }
    return _pixelData;
}
- (void)dealloc {
    CGContextRelease(ctx);
}
@end
CGContextRef createContext(CGSize size,CGFloat scale ,void* bitmapBuffer){
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(bitmapBuffer, (int) scale* size.width, (int)scale * size.height, 8, 0, space, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    
    CGContextScaleCTM(ctx, scale, scale);
    CGColorSpaceRelease(space);
    return ctx;
}
CGContextRef createContextNoAlpha(CGSize size,CGFloat scale,CGColorRef fillColor,void* bitmapBuffer){
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             bitmapBuffer,
                                             (int)size.width * scale,
                                             (int)size.height * scale,
                                             8,
                                             0,
                                             space,
                                             kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextScaleCTM(ctx, scale, scale);
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, fillColor);
    CGContextFillRect(ctx, (CGRect){0,0,size.width,size.height});
    CGContextRestoreGState(ctx);
    CGColorSpaceRelease(space);
    return ctx;
    
}
CGImageRef CGBitMapExportPNG(CGImageRef img,CGFloat quality) {
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorSystemDefault, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, NULL);
    CFNumberRef number = CFNumberCreate(kCFAllocatorSystemDefault, kCFNumberFloatType, &quality);
    CFTypeRef v[1];
    CFTypeRef n[1];
    v[0] = kCGImageDestinationLossyCompressionQuality;
    n[0] = number;
    
    CFDictionaryRef property = CFDictionaryCreate(kCFAllocatorSystemDefault, (const void**)&v, (const void**)&n, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CGImageDestinationAddImage(destination, img, property);
    CGImageDestinationFinalize(destination);
    
    CGImageSourceRef source = CGImageSourceCreateWithData(data, nil);
    CGImageRef result = CGImageSourceCreateImageAtIndex(source, 0, nil);
    
    CGImageRelease(img);
    CFRelease(data);
    CFRelease(destination);
    CFRelease(number);
    CFAutorelease(property);
    CFRelease(source);
    return result;
}
CGImageRef CGBitContextExportPNG(CGContextRef ctx,CGFloat quality){
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    return CGBitMapExportPNG(img,quality);
}
CGImageRef CGBitContextExportJPG(CGContextRef ctx,CGFloat quality){
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorSystemDefault, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, NULL);
    CFNumberRef number = CFNumberCreate(kCFAllocatorSystemDefault, kCFNumberFloatType, &quality);
    CFTypeRef v[1];
    CFTypeRef n[1];
    v[0] = kCGImageDestinationLossyCompressionQuality;
    n[0] = number;
    
    CFDictionaryRef property = CFDictionaryCreate(kCFAllocatorSystemDefault, (const void**)&v, (const void**)&n, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CGImageDestinationAddImage(destination, img, property);
    CGImageDestinationFinalize(destination);
    
    CGImageSourceRef source = CGImageSourceCreateWithData(data, nil);
    CGImageRef result = CGImageSourceCreateImageAtIndex(source, 0, nil);
    
    CGImageRelease(img);
    CFRelease(data);
    CFRelease(destination);
    CFRelease(number);
    CFAutorelease(property);
    CFRelease(source);
    return result;
}

CIImage * CGBitmapContextGetCIImage(CGContextRef ctx) {
    
    size_t pr = CGBitmapContextGetBytesPerRow(ctx);
    
    size_t h = CGBitmapContextGetHeight(ctx);
    
    size_t w = CGBitmapContextGetWidth(ctx);
    
    NSUInteger len = pr * h;
    
    NSData* data = [[NSData alloc] initWithBytes:CGBitmapContextGetData(ctx) length:len];
    return [[CIImage alloc] initWithBitmapData:data bytesPerRow:pr size:CGSizeMake(w, h) format:kCIFormatRGBA8 colorSpace:CGBitmapContextGetColorSpace(ctx)];
}
