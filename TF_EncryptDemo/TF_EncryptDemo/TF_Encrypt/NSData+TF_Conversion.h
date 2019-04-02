//
//  NSData+TF_Conversion.h
//  TF_EncryptDemo
//
//  Created by Twisted Fate on 2019/4/1.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (TF_Conversion)

+ (NSData *)dataFromShort:(short)value;

+ (NSData *)dataFromInt:(int)value;

+ (NSData *)currentTimeData;

+ (NSData *)timestampData;

@end

NS_ASSUME_NONNULL_END
