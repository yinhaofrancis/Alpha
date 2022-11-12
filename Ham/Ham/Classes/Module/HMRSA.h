//
//  HMRSA.h
//  Ham_Example
//
//  Created by hao yin on 2020/5/3.
//  Copyright © 2020 yinhaofrancis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HMKeySize) {
    HMKeySize512 = 512,
    HMKeySize768 = 768,
    HMKeySize1024 = 1024,
    HMKeySize2048 = 2048
};

@interface HMkeyPair : NSObject
@property(nonatomic,readonly)SecKeyRef privateKey;
@property(nonatomic,readonly)SecKeyRef publicKey;
@property(nonatomic,readonly)NSDictionary *parameter;

+ (instancetype)KeyRSAPair:(HMKeySize)keySize;
@end

@interface HMRSA : NSObject

@property(nonatomic,readonly) HMkeyPair *keyPair;

@property(nonatomic,readonly) SecPadding padding;

- (instancetype)initWithKeyPair:(HMkeyPair *)keyPair padding:(SecPadding)padding;

- (instancetype)initWithKeyPair:(HMkeyPair *)keyPair;

- (NSData *)encrypt:(NSData *)data;

- (NSData *)decrypt:(NSData *)data;

- (NSData *)sign:(NSData *)data;

- (BOOL)verify:(NSData *)data signKey:(NSData *)key;


- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
