//
//  NSArray+Extension.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/20.
//  Copyright © 2018年 All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extension)

// 获取随机字符列表
+ (instancetype)code_randomListWithLength:(NSInteger)length;

/** 返回一个字符串格式的数组 */
+ (NSString*)code_randomStringWithLength:(NSInteger)length;

/** 文件的总大小 */
- (NSUInteger)code_fileSize;

@end
