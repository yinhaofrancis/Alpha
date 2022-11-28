//
//  BIAnotationStorage.m
//   
//
//  Created by hao yin on 2019/7/5.
//

#import "BIAnotationStorage.h"
@implementation BIAnotationStorage{
    NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,NSString *> *> * storage;
    dispatch_semaphore_t lock;
}
+(instancetype)shared{
    static BIAnotationStorage* storage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[BIAnotationStorage alloc] init];
    });
    return storage;
}
-(instancetype)init{
    self = [super init];
    if(self){
        storage = [[NSMutableDictionary alloc] init];
        lock = dispatch_semaphore_create(1);
    }
    return self;
}
- (void)addBaseClass:(NSString *)name name:(NSString *)key impClassName:(Class)value{
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if(!storage[name]){
        storage[name] = [[NSMutableDictionary alloc] init];
    }
    storage[name][key] = (id)value;
    dispatch_semaphore_signal(lock);
}
- (NSDictionary *)getEnvConfigByName:(NSString *)name{
    return [storage[name] copy];
}

@end

@implementation BIBlockAnotationStorage{
    NSMutableDictionary* dic;
}
@dynamic map;
+ (instancetype)shared{
    static BIBlockAnotationStorage* storage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[BIBlockAnotationStorage alloc] init];
    });
    return storage;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        dic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)addkey:(NSString *)key value:(id)value{
    dic[key] = value;
}
- (void)addDictionary:(NSDictionary *)dic{
    [self->dic addEntriesFromDictionary:dic];
}
- (NSDictionary *)map{
    return dic.copy;
}
@end
