//
//  HMCrypto.m
//  Ham
//
//  Created by KnowChat02 on 2019/9/5.
//

#import "HMCrypto.h"


typedef int (*SHA_INIT)     (const void * ctx);
typedef int (*SHA_UPDATE)   (const void *ctx, const void *data, CC_LONG len);
typedef int (*SHA_FINAL)    (unsigned char *md, const void *c);
@implementation HMHash{
    SHA_INIT sha_init;
    SHA_UPDATE sha_update;
    SHA_FINAL sha_final;
    CC_LONG len;
    void * ctx;
    size_t ctxSize;
/// HMAC
    CCHmacContext hmacCtx;
    CCHmacAlgorithm alg;
    BOOL isHmac;
}

- (instancetype)initWithHashFamily:(HashFamily)family{
    if(family == HashFamilySha1){
        sha_init = (SHA_INIT)CC_SHA1_Init;
        sha_update = (SHA_UPDATE)CC_SHA1_Update;
        sha_final = (SHA_FINAL)CC_SHA1_Final;
        len = CC_SHA1_DIGEST_LENGTH;
        ctxSize = sizeof(CC_SHA1_CTX);
    }else if(family == HashFamilySha256){
        sha_init = (SHA_INIT)CC_SHA256_Init;
        sha_update = (SHA_UPDATE)CC_SHA256_Update;
        sha_final = (SHA_FINAL)CC_SHA256_Final;
        len = CC_SHA256_DIGEST_LENGTH;
        ctxSize = sizeof(CC_SHA256_CTX);
    }else if(family == HashFamilySha224){
        sha_init = (SHA_INIT)CC_SHA224_Init;
        sha_update = (SHA_UPDATE)CC_SHA224_Update;
        sha_final = (SHA_FINAL)CC_SHA224_Final;
        len = CC_SHA224_DIGEST_LENGTH;
        ctxSize = sizeof(CC_SHA256_CTX);
    }else if(family == HashFamilySha384){
        sha_init = (SHA_INIT)CC_SHA384_Init;
        sha_update = (SHA_UPDATE)CC_SHA384_Update;
        sha_final = (SHA_FINAL)CC_SHA384_Final;
        len = CC_SHA384_DIGEST_LENGTH;
        ctxSize = sizeof(CC_SHA512_CTX);
    }else if(family == HashFamilySha512){
        sha_init = (SHA_INIT)CC_SHA512_Init;
        sha_update = (SHA_UPDATE)CC_SHA512_Update;
        sha_final = (SHA_FINAL)CC_SHA512_Final;
        len = CC_SHA512_DIGEST_LENGTH;
        ctxSize = sizeof(CC_SHA512_CTX);
    }else{
        return nil;
    }
    self = [super init];
    ctx = malloc(ctxSize);
    if(self){
        sha_init(ctx);
    }
    return self;
}
- (instancetype)initWithHMACkey:(NSData *)key hashFamily:(HashFamily)hf {
    self = [super init];
    if (self) {
        isHmac = true;
        switch (hf) {
            case HashFamilySha1:
                alg = kCCHmacAlgSHA1;
                len = CC_SHA1_DIGEST_LENGTH;
                break;
            case HashFamilySha224:
                alg = kCCHmacAlgSHA224;
                len = CC_SHA224_DIGEST_LENGTH;
                break;
            case HashFamilySha256:
                alg = kCCHmacAlgSHA256;
                len = CC_SHA256_DIGEST_LENGTH;
                break;
            case HashFamilySha384:
                alg = kCCHmacAlgSHA384;
                len = CC_SHA384_DIGEST_LENGTH;
                break;
            case HashFamilySha512:
                alg = kCCHmacAlgSHA512;
                len = CC_SHA512_DIGEST_LENGTH;
                break;
        }
        CCHmacInit(&hmacCtx, alg, key.bytes, key.length);
    }
    return self;
}

- (BOOL)isHMACMode{
    return self.isHMACMode;
}

- (NSData *)hashData{
    if(isHmac){
        unsigned char * code = malloc(len);
        CCHmacFinal(&hmacCtx, code);
        
        NSData * data = [[NSData alloc] initWithBytes:code length:len];
        free(code);
        return data;
    }else{
        unsigned char * code = malloc(len);
        sha_final(code,ctx);
        NSData *codeData = [[NSData alloc] initWithBytes:code length:len];
        sha_init(ctx);
        return codeData;
    }
}
- (HMHash *)insertData:(NSData *)data{
    if(isHmac){
        CCHmacUpdate(&hmacCtx, data.bytes, data.length);
    }else{
        sha_update(ctx,data.bytes,(CC_LONG)data.length);
    }
    return self;
}
- (void)dealloc{
    free(ctx);
}

+ (NSData *)hashData:(NSData *)resource hashFamily:(HashFamily)family{
    return [[[[HMHash alloc] initWithHashFamily:family] insertData:resource] hashData];
}

+ (NSData *)hmacHashData:(NSData *)resource key:(NSData *)key hashFamily:(HashFamily)family{
    return [[[[HMHash alloc] initWithHMACkey:key hashFamily:family] insertData:resource]hashData];
}
@end
@implementation NSData (HEX)
-(NSString *)toHexString{
 
    NSMutableString* hexCode = [[NSMutableString alloc] init];
    
    for (int i = 0; i < self.length; i ++) {
        uint8_t* c = (uint8_t *)self.bytes;
        [hexCode appendString:[NSString stringWithFormat:@"%02x",*(c + i)]];
    }
    
    return hexCode;
}
-(instancetype)initWithHex:(NSString *)hex{
    if (!hex|| [hex length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([hex length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [hex length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [hex substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}
@end

@implementation HMCrypto{
    CCCryptorRef cryptor;
    NSMutableData* result;
    CCMode cmode;
    BOOL isFinal;
}

- (instancetype)initWithEncrypt:(CCOperation)op
                           mode:(HMCryptoMode)mode
                      Algorithm:(CCAlgorithm)alg
                        padding:(CCPadding)padding
                            key:(NSData *)key
                          ivKey:(NSData *)iv
                          tweak:(NSData *)tweakData
                   numberRounds:(int)numRound
{
    self = [super init];
    if (self) {
        cmode = mode;
        result = [NSMutableData new];
        void *ivd = 0;
        void *tweakd = 0;
        size_t tweakSize = 0;
        if(iv != nil){
            size_t ivSize = [self ivSize:alg];
            ivd = malloc(ivSize);
            memset(ivd, 0, ivSize);
            memcpy(ivd, iv.bytes, MIN(ivSize, iv.length));
        }
        if(tweakData != nil){
            tweakSize = [self keySize:alg key:key];
            tweakd = malloc(tweakSize);
            memset(tweakd, 0, tweakSize);
            memcpy(tweakd, tweakData.bytes, MIN(tweakSize, tweakData.length));
        }
        size_t keySize = [self keySize:alg key:key];
        void *keyd = malloc(keySize);
        memset(keyd, 0, keySize);
        memcpy(keyd, key.bytes, MIN(keySize, key.length));
        if (CCCryptorCreateWithMode(op, mode, alg, padding, ivd, keyd, keySize, tweakd, tweakSize,numRound, kCCModeOptionCTR_BE, &cryptor) != kCCSuccess){
            return nil;
        }
        free(keyd);
        free(ivd);
        free(tweakd);
    }
    return self;
}
-(instancetype)initWithEncryptAlgorithm:(CCAlgorithm)alg option:(CCOptions)options key:(NSData *)key ivKey:(NSData *)iv{
    //    return [self initWithEncrypt:kCCEncrypt Algorithm:alg option:options key:key ivKey:iv];
    return nil;
}
-(size_t)keySize:(CCAlgorithm) alg key:(NSData*)key{
    if(alg == kCCAlgorithmAES){
        if(kCCKeySizeAES128 >= key.length){
            return kCCKeySizeAES128;
        }
        if(kCCKeySizeAES192 >= key.length){
            return kCCKeySizeAES192;
        }else{
            return kCCKeySizeAES256;
        }
    }
    if(alg == kCCAlgorithmDES){
        return kCCKeySizeDES;
    }
    if(alg == kCCAlgorithm3DES){
        return kCCKeySize3DES;
    }
    if(alg == kCCAlgorithmCAST){
        return kCCKeySizeMinCAST > key.length ? kCCKeySizeMinCAST :(kCCKeySizeMaxCAST < key.length ? kCCKeySizeMaxCAST : key.length);
    }
    if(alg == kCCAlgorithmRC4){
        return kCCKeySizeMinRC4 > key.length ? kCCKeySizeMinRC4 :(kCCKeySizeMaxRC4 < key.length ? kCCKeySizeMaxRC4 : key.length);
    }
    if(alg == kCCAlgorithmRC2){
        return kCCKeySizeMinRC2 > key.length ? kCCKeySizeMinRC2 :(kCCKeySizeMaxRC2 < key.length ? kCCKeySizeMaxRC2 : key.length);
    }
    if(alg == kCCAlgorithmBlowfish){
        return kCCKeySizeMinBlowfish > key.length ? kCCKeySizeMinBlowfish :(kCCKeySizeMaxBlowfish < key.length ? kCCKeySizeMaxBlowfish : key.length);
    }
    return 0;
}
-(size_t)ivSize:(CCAlgorithm) alg{
    if(alg == kCCAlgorithmAES){
        return kCCBlockSizeAES128;
    }
    if(alg == kCCAlgorithmDES){
        return kCCBlockSizeDES;
    }
    if(alg == kCCAlgorithm3DES){
        return kCCBlockSize3DES;
    }
    if(alg == kCCAlgorithmCAST){
        return kCCBlockSizeCAST;
    }
    if(alg == kCCAlgorithmRC4){
        return kCCBlockSizeRC2;
    }
    if(alg == kCCAlgorithmRC2){
        return kCCBlockSizeRC2;
    }
    if(alg == kCCAlgorithmBlowfish){
        return kCCBlockSizeBlowfish;
    }
    return 0;
}
-(BOOL)update:(NSData *)data{
    if(isFinal){
        result = [[NSMutableData alloc] init];
        isFinal = false;
    }
    size_t size = CCCryptorGetOutputLength(cryptor, data.length, false);
    size_t realSize = 0;
    void* buffer = malloc(size);
    CCCryptorStatus flag = CCCryptorUpdate(cryptor, data.bytes, data.length, buffer, size, &realSize);
    if (flag == kCCSuccess){
        [result appendBytes:buffer length:realSize];
        free(buffer);
        return true;
    }
    free(buffer);
    return false;
}
-(BOOL)finalCrypto{
    isFinal = true;
    size_t size = CCCryptorGetOutputLength(cryptor, 0, true);
    size_t realSize = 0;
    void* buffer = malloc(size);
    CCCryptorStatus flag = CCCryptorFinal(cryptor, buffer, size, &realSize);
    if(flag == kCCSuccess){
        [result appendBytes:buffer length:realSize];
        free(buffer);
        return true;
    }
    free(buffer);
    return false;
}
- (NSData *)result{
    return result;
}
- (void)dealloc{
    CCCryptorRelease(cryptor);
}
@end
