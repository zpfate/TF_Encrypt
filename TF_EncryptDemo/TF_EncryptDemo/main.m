//
//  main.m
//  TF_EncryptDemo
//
//  Created by Twisted Fate on 2019/3/31.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+TF_Encrypt.h"
#import "NSData+TF_Conversion.h"
#import <CommonCrypto/CommonCrypto.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSString *iv = nil;
        char ivBytes[kCCBlockSizeAES128 + 1];
        bzero(ivBytes, sizeof(ivBytes));
        [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
        
        
        NSData *helloData = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *lengthData = [NSData dataFromShort:helloData.length];
        NSLog(@"lenghtData === %@", lengthData);
        
        
        // AES128
        
        NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"data === %@", data);

        NSString *key = @"key";
        NSData *encryptData = [data tf_encryptAES128WithKey:key iv:@"iv"];
        NSLog(@"encryptData === %@", encryptData);

        NSData *decryptData = [encryptData tf_decryptAES128WithKey:key iv:@"iv"];
        NSLog(@"decryptData === %@", decryptData);
        
    }
    return 0;
}



