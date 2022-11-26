//
//  BIAnotationStorage.h
//   
//
//  Created by hao yin on 2019/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BIAnotationStorage : NSObject
+ (instancetype)shared;
- (void)addBaseClass:(NSString*)name name:(NSString *)key impClassName:(Class)value;
- (NSDictionary *)getEnvConfigByName:(NSString *)name;
@end

@interface BIBlockAnotationStorage : NSObject
+ (instancetype)shared;
- (void)addkey:(NSString *)key value:(id)value;
- (void)addDictionary:(NSDictionary *)dic;
@property(nonatomic,readonly)NSDictionary *map;
@end

NS_ASSUME_NONNULL_END
