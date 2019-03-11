//
//  GarbageCodeCore.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GarbageCodeCore : NSObject

/** 混淆dir下的所有类名、方法名 */
+ (void)obfuscateAtDir:(NSString *)dir
              prefixes:(NSArray *)prefixes
              progress:(void (^)(NSString *detail))progress
            completion:(void (^)(NSString *fileContent))completion;

/**
 垃圾代码|代码混淆
 
 @param dir 文件名|文件夹
 @param progress 进度
 */
+ (void)generateCodeAtDir:(NSString *)dir
           dispatch_queue:(dispatch_queue_t)queue
                 progress:(void (^)(NSString *detail))progress
               completion:(void (^)(NSString *tips,BOOL isEnableButton))completion;

/** 转换编码 */
+ (void)convertEncodingInDir:(NSString *)dir
              dispatch_queue:(dispatch_queue_t)queue
                    progress:(void (^)(NSString *detail))progress
                  completion:(void (^)(NSString *tips,BOOL isEnableButton))completion;

@end
