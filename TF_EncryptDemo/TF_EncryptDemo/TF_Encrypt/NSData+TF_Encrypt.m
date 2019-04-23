//
//  NSData+TF_Encrypt.m
//  TF_EncryptDemo
//
//  Created by Twisted Fate on 2019/3/31.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import "NSData+TF_Encrypt.h"
#import <CommonCrypto/CommonCrypto.h>

//#import <CommonCrypto/CommonDigest.h>

static const NSInteger kStaticPrfMinimumLength = 96;

@implementation NSData (AES128)

- (NSData *)tf_encryptAES128WithKey:(NSString *)key iv:(NSString *)iv {
    return [self tf_AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)tf_decryptAES128WithKey:(NSString *)key iv:(NSString *)iv {
    return [self tf_AES128Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)tf_encryptAES128WithKeyData:(NSData *)keyData ivData:(NSData *)ivData {
    return [self tf_AES128Operation:kCCEncrypt keyData:keyData ivData:ivData];
}

- (NSData *)tf_decryptAES128WithKeyData:(NSData *)keyData ivData:(NSData *)ivData {
    return [self tf_AES128Operation:kCCDecrypt keyData:keyData ivData:ivData];
}

/**
 *
 *  @param operation kCCEncrypt:加密  kCCDecrypt:解密
 *  @param key       公钥t:
 *  @param iv        偏移量
 *
 *  @return 加密或者解密的NSData
 */

- (NSData *)tf_AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv {
    
    char keyBytes[kCCKeySizeAES128 + 1];  //kCCKeySizeAES128是加密位数 可以替换成256位的
    
    // bzero函数:从字符串第一位开始置0, 第二个参数代表置0的位数
    // 相当于memset(keyBytes,0x00,sizeof(keyBytes));
    bzero(keyBytes, sizeof(keyBytes));
    [key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];
    
    // iv
    char ivBytes[kCCBlockSizeAES128 + 1];
    bzero(ivBytes, sizeof(ivBytes));
    [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    return [self tf_cryptAES128Operation:operation keyBytes:keyBytes ivBytes:ivBytes];
}


- (NSData *)tf_AES128Operation:(CCOperation)operation keyData:(NSData *)keyData ivData:(NSData *)ivData {

    char keyBytes[kCCKeySizeAES128 + 1];
    bzero(keyBytes, sizeof(keyBytes));
    [keyData getBytes:keyBytes length:sizeof(keyBytes)];
    
    char ivBytes[kCCKeySizeAES128 + 1];
    bzero(ivBytes, sizeof(ivBytes));
    [ivData getBytes:ivBytes length:sizeof(ivBytes)];
    
    return [self tf_cryptAES128Operation:operation keyBytes:keyBytes ivBytes:ivBytes];
}

- (NSData *)tf_cryptAES128Operation:(CCOperation)operation keyBytes:(void *)keyBytes ivBytes:(void *)ivBytes {
    
    size_t bufferSize = self.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesCrypted = 0;
    
    /*
     CCOptions 默认为CBC加密
     选择ECB加密填: kCCOptionPKCS7Padding | kCCOptionECBMode
     kCCOptionPKCS7Padding: 7填充
     直接填0x0000: 就是No padding填充
     */
    
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding,
                                            keyBytes,
                                            kCCKeySizeAES128,
                                            ivBytes,
                                            self.bytes,
                                            self.length,
                                            buffer,
                                            bufferSize,
                                            &numBytesCrypted);
    
    if(cryptorStatus == kCCSuccess) {
        NSLog(@"Crypt Successfully");

        NSData *result = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    /* 转16进制字符串 */
        Byte *resultBytes = (Byte *)result.bytes;
        NSMutableString *outPut = [[NSMutableString alloc] initWithCapacity:result.length * 2];
        for (int i = 0; i < result.length; i++) {
            [outPut appendFormat:@"%02x", resultBytes[i]];
        }

        return result;
        
    } else {
        NSLog(@"Crypt Error");
        free(buffer);
        return nil;
    }
}

@end


@implementation NSData (PRF)

+ (NSData *)tf_prfSecret:(NSData *)secret label:(NSData *)label seed:(NSData *)seed {
    
    NSMutableData *seedData = [NSMutableData data];
    [seedData appendData:label];
    [seedData appendData:seed];
    return [self tf_prfSecret:secret seed:seedData];
}

+ (NSData *)tf_prfSecret:(NSData *)secret seed:(NSData *)seed {
    
    NSMutableData *prfData = [NSMutableData data];
    NSMutableData *mutableData = [NSMutableData dataWithData:seed];
    NSData *AnData = [NSData dataWithData:seed];
    
    // 需要prf算法得出的长度
    while (prfData.length < kStaticPrfMinimumLength) {
        AnData = [self hmacSHA256WithSecret:secret content:AnData];
        mutableData = [NSMutableData dataWithData:AnData];
        [mutableData appendData:seed];
        NSData *hmacData = [self hmacSHA256WithSecret:secret content:mutableData];
        [prfData appendData:hmacData];
    }
    return prfData;
}

@end

@implementation NSData (HMAC)

// hmac sha256算法
+ (NSData *)hmacSHA256WithSecret:(NSData *)secret content:(NSData *)content {
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, secret.bytes, secret.length, content.bytes, content.length, cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    //    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    //    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    //    for (int i = 0; i < HMACData.length; ++i){
    //        [HMAC appendFormat:@"%02x", buffer[i]];
    return HMACData;
}


// SHA256签名
+ (NSData *)SHA256:(NSData *)encryptData {
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(encryptData.bytes, (CC_LONG)encryptData.length, digest);
    NSData *result = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    return result;
}

@end
