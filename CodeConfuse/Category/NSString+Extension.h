//
//  NSString+Extension.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/17.
//  Copyright © 2018年 All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (Extension)

/** 生成length长度的随机字符串（不包含数字） */
+ (instancetype)code_randomStringWithoutDigital;

/** 生成length长度的随机字符串（不包含数字） */
+ (instancetype)code_randomStringWithoutDigital:(NSString *)prefix;

/** 去除空格 */
- (instancetype)code_stringByRemovingSpace;

/** 首字母大写 */
+ (NSString *)captializedFirstCharOfString:(NSString *)string;

/** 将字符串用空格分割成数组 */
- (NSArray *)code_componentsSeparatedBySpace;

/** 从mainBundle中加载文件数据 */
+ (instancetype)code_stringWithFilename:(NSString *)filename
                            extension:(NSString *)extension;

/** 生成MD5 */
- (NSString *)code_MD5;

/** 生成crc32 */
- (NSString *)code_crc32;

@end


@interface NSString (URL)

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString;

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString;

@end

