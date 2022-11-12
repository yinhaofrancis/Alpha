//
//  HMRSA.m
//  Ham_Example
//
//  Created by hao yin on 2020/5/3.
//  Copyright © 2020 yinhaofrancis. All rights reserved.
//

#import "HMRSA.h"

@implementation HMRSA
- (NSData *)encrypt:(NSData *)data {
    
    uint8_t dataBuffer[2048];
    size_t len;
    OSStatus ret = SecKeyEncrypt(self.keyPair.publicKey,
                                 self.padding,
                                 data.bytes,
                                 data.length,
                                 dataBuffer,
                                 &len);
    if(ret == errSecSuccess){
       return [[NSData alloc] initWithBytes:dataBuffer length:len];
    }
    return nil;
}
- (NSData *)decrypt:(NSData *)data {
    uint8_t dataBuffer[2048];
    size_t len;
    OSStatus ret = SecKeyDecrypt(self.keyPair.privateKey,
                                 self.padding,
                                 data.bytes,
                                 data.length,
                                 dataBuffer,
                                 &len);
    if(ret == errSecSuccess){
       return [[NSData alloc] initWithBytes:dataBuffer length:len];
    }
    return nil;
}
- (NSData *)sign:(NSData *)data {
    size_t len = SecKeyGetBlockSize(self.keyPair.privateKey);
    uint8_t* dataBuffer = malloc(len);
    
    OSStatus ret = SecKeyRawSign(self.keyPair.privateKey,
                                 self.padding,
                                 data.bytes,
                                 data.length,
                                 dataBuffer,
                                 &len);
    if(ret == errSecSuccess){
        NSData * data = [[NSData alloc] initWithBytes:dataBuffer length:len];
        free(dataBuffer);
        return data;
    }
    free(dataBuffer);
    return nil;
}
- (BOOL)verify:(NSData *)data signKey:(NSData *)key{
    
    OSStatus ret = SecKeyRawVerify(self.keyPair.publicKey,
                                 self.padding,
                                 data.bytes,
                                 data.length,
                                   key.bytes,
                                   key.length);
    if(ret == errSecSuccess){
        return true;
    }
    return false;
}
- (instancetype)initWithKeyPair:(HMkeyPair *)keyPair{

    return [self initWithKeyPair:keyPair padding:kSecPaddingNone];
}
- (instancetype)initWithKeyPair:(HMkeyPair *)keyPair padding:(SecPadding)padding {
    self = [super init];
    if(self) {
        _keyPair = keyPair;
        _padding = padding;
    }
    return self;
}
@end

@implementation HMkeyPair

- (instancetype)initWithParameter:(NSDictionary *)param
{
    self = [super init];
    if (self) {
        OSStatus err = SecKeyGeneratePair((CFDictionaryRef)param, &(_publicKey), &(_privateKey));
        _parameter = [param copy];
        if(err != errSecSuccess) {
            return nil;
        }
    }
    return self;
}

+ (instancetype)KeyRSAPair:(HMKeySize)keySize{
    NSDictionary* attr = \
    @{
        (id)kSecAttrKeyType:(id)kSecAttrKeyTypeRSA,
        (id)kSecAttrKeySizeInBits:@(keySize)
    };
    return [[HMkeyPair alloc] initWithParameter:attr];
}
- (void)dealloc
{
    CFRelease(self.publicKey);
    CFRelease(self.privateKey);
}
@end
