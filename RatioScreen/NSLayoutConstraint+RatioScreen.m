////
////  NSLayoutConstraint+RatioScreen.m
////  RatioScreen
////
////  Created by wenyang on 2022/9/24.
////
//
//#import "NSLayoutConstraint+RatioScreen.h"
//#import "objc/runtime.h"
//#define markScreenRatioKey "__markScreenRatio__"
//
//@implementation NSLayoutConstraint (RatioScreen)
//+ (void)load{
//    [super load];
//    Method m1 = class_getInstanceMethod(NSLayoutConstraint.class, @selector(setConstant:));
//    Method m2 = class_getInstanceMethod(NSLayoutConstraint.class, @selector(constant));
//    Method m3 = class_getInstanceMethod(NSLayoutConstraint.class, @selector(_setConstant:));
//    Method m4 = class_getInstanceMethod(NSLayoutConstraint.class, @selector(_constant));
//    method_exchangeImplementations(m1, m3);
//    method_exchangeImplementations(m2, m4);
//}
//-(void)_setConstant:(CGFloat)constant{
//    [self _setConstant:constant];
//}
//-(CGFloat)_constant{
//    if(self.markScreenRatio){
//        return [self _constant] * RSScreenConfigration.shared.ratio;
//    }else{
//        return [self _constant];
//    }
//}
//
//- (BOOL)markScreenRatio{
//    return [objc_getAssociatedObject(self, markScreenRatioKey) boolValue];
//}
//- (void)setMarkScreenRatio:(BOOL)markScreenRatio{
//    objc_setAssociatedObject(self, markScreenRatioKey, @(markScreenRatio), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//- (instancetype)markToScreenRatio:(BOOL)markScreenRatio{
//    self.markScreenRatio = markScreenRatio;
//    return self;
//}
//@end
//
//@implementation  RSScreenConfigration
//
//+ (RSScreenConfigration *)shared{
//    static dispatch_once_t onceToken;
//    static RSScreenConfigration *config;
//    dispatch_once(&onceToken, ^{
//        config = [RSScreenConfigration new];
//    });
//    return config;
//}
//- (CGFloat)ratio{
//    if ((int)self.designSize.width == 0){
//        return 1;
//    }
//    return UIScreen.mainScreen.bounds.size.width / self.designSize.width;
//}
//
//- (void)setDesignSize:(CGSize)designSize{
//    _designSize = designSize;
//}
//@end
//
//@implementation UIFont (RatioScreen)
//+ (void)load{
//    [super load];
//    {
//    
//        Method m1 = class_getClassMethod(UIFont.class, @selector(fontWithDescriptor:size:));
//        Method m2 = class_getClassMethod(UIFont.class, @selector(_fontWithDescriptor:size:));
//        method_exchangeImplementations(m1, m2);
//    }
////    {
////        Method m1 = class_getInstanceMethod(UIFont.class, @selector(pointSize));
////
////        Method m2 = class_getInstanceMethod(UIFont.class, @selector(_pointSize));
////        method_exchangeImplementations(m1, m2);
////    }
////    {
////        Method m1 = class_getInstanceMethod(UIFont.class, @selector(ascender));
////
////        Method m2 = class_getInstanceMethod(UIFont.class, @selector(_ascender));
////        method_exchangeImplementations(m1, m2);
////    }
////    {
////        Method m1 = class_getInstanceMethod(UIFont.class, @selector(descender));
////
////        Method m2 = class_getInstanceMethod(UIFont.class, @selector(_descender));
////        method_exchangeImplementations(m1, m2);
////    }
//}
////- (CGFloat)_pointSize{
////    return [self _pointSize] * RSScreenConfigration.shared.ratio;
////}
////- (CGFloat)_ascender{
////    return [self _ascender] * RSScreenConfigration.shared.ratio;
////}
////- (CGFloat)_descender{
////    return [self _descender] * RSScreenConfigration.shared.ratio;
////}
//+(UIFont *)_fontWithDescriptor:(UIFontDescriptor *)descriptor size:(CGFloat)pointSize{
//    return [self _fontWithDescriptor:descriptor size:pointSize];
//}
//
//@end
