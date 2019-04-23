//
//  NSData+TF_Conversion.m
//  TF_EncryptDemo
//
//  Created by Twisted Fate on 2019/4/1.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import "NSData+TF_Conversion.h"

@implementation NSData (TF_Conversion)

- (NSInteger)integerValueWithRange:(NSRange)range {
    
    NSData *subData = [self subdataWithRange:range];
    return [subData integerValue];
}

- (NSInteger)integerValue {
    
    Byte bytes[self.length];
    [self getBytes:&bytes range:NSMakeRange(0, self.length)];
    int mask = 0xff;
    int temp = 0;
    int value = 0;
    for (int i = 0;i < self.length; i++) {
        value <<= 8;
        temp = bytes[i] & mask;
        value |= temp;
    }
    return value;
}

+ (NSData *)dataFromShort:(short)value {
    Byte bytes[2] = {};
    for (int i = 0; i < 2; i++) {
        int offset = 16 - (i + 1) * 8;
        bytes[i] = (Byte) ((value >> offset) & 0xff);
    }
    NSData *data = [[NSData alloc] initWithBytes:bytes length:2];
    return data;
}

+ (NSData *)dataFromInt:(int)value {
    
    Byte bytes[4] = {};
    for (int i = 0; i < 4; i++) {
        bytes[i] = (Byte)(value >> (24 - i * 8));
    }
    NSData *data= [[NSData alloc] initWithBytes:bytes length:4];
    return data;
}

+ (NSData *)currentTimeData {
    
    Byte bytes[6];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    
    int year =(int) [dateComponent year];
    int month = (int) [dateComponent month];
    int day = (int) [dateComponent day];
    int hour = (int) [dateComponent hour];
    int minute = (int) [dateComponent minute];
    int second = (int) [dateComponent second];
    
    bytes[0] = year - 2000;
    bytes[1] = month;
    bytes[2] = day;
    bytes[3] = hour;
    bytes[4] = minute;
    bytes[5] = second;
    return [[NSData alloc] initWithBytes:bytes length:6];
}

+ (NSData *)timestampData {
    int time = [[NSDate date] timeIntervalSince1970];
    return [NSData dataFromInt:time];
}

@end
