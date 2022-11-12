//
//  HMCrypto.h
//  Ham
//
//  Created by KnowChat02 on 2019/9/5.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HashFamily) {
    HashFamilySha1,
    HashFamilySha224,
    HashFamilySha256,
    HashFamilySha384,
    HashFamilySha512
};
//@interface HMCrypto : NSObject
//+(NSData *)hash:(NSData *) data hashFamily:(HashFamily)type;
//@end

@interface HMHash : NSObject
- (nullable instancetype)initWithHashFamily:(HashFamily)family;

- (nullable instancetype)initWithHMACkey:(NSData *)key hashFamily:(HashFamily)hf;

- (BOOL)isHMACMode;

-(HMHash *)insertData:(NSData*)data;

-(NSData *)hashData;

+(NSData*)hashData:(NSData *)resource hashFamily:(HashFamily)family;

+(NSData*)hmacHashData:(NSData *)resource key:(NSData *)key hashFamily:(HashFamily)family;
@end

typedef NS_ENUM(uint32_t, HMCryptoMode) {
    HMCryptoModeECB        = 1,
    HMCryptoModeCBC        = 2,
    HMCryptoModeCFB        = 3,
    HMCryptoModeCTR        = 4,
    HMCryptoModeF8         = 5, // Unimplemented for now (not included)
    HMCryptoModeLRW        = 6, // Unimplemented for now (not included)
    HMCryptoModeOFB        = 7,
    HMCryptoModeXTS        = 8,
    HMCryptoModeRC4        = 9,
    HMCryptoModeCFB8
};

@interface HMCrypto : NSObject
@property(nonatomic,readonly)NSData* result;
- (instancetype)initWithEncrypt:(CCOperation)op
                           mode:(HMCryptoMode)mode
                      Algorithm:(CCAlgorithm)alg
                        padding:(CCPadding)padding
                            key:(NSData *)key
                          ivKey:(nullable NSData *)iv
                          tweak:(nullable NSData *)tweakData
                   numberRounds:(int)numRound;
-(BOOL)update:(NSData *)data;
-(BOOL)finalCrypto;
@end


@interface NSData (HEX)
- (NSString *)toHexString;
- (instancetype)initWithHex:(NSString *)hex;
@end

NS_ASSUME_NONNULL_END
