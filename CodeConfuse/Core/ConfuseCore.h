//
//  ConfuseCore.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/17.
//  Copyright © 2018年 All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>

typedef void (^ConfuseProgressBlock)(NSString *tip);

@interface ConfuseCore : NSObject

@property (nonatomic, copy) NSString *projectRootPath;
@property (nonatomic, strong) NSArray *ignoreDirNames;
@property (nonatomic, copy) ConfuseProgressBlock progressBlock;

//是否高强度混淆
@property (assign,nonatomic) BOOL isHighLevelConfuse;
//用户自定义前缀(用于类名/方法或者函数/属性或者成员变量)
@property (nonatomic, copy) NSString *customPrefixString;

+ (instancetype)sharedInstance;

+ (void)modifyClassNamePrefix:(NSMutableString *)projectContent source:(NSString *)sourceCodeDir ignore:(NSArray<NSString *> *)ignoreDirNames oldPrefix:(NSString *)oldName newPrefix:(NSString *)newName;

+ (void)modifyFilesClassNameInDir:(NSString *)sourceCodeDir oldName:(NSString *)oldClassName newName:(NSString *)newClassName;

+ (void)confuseCodeAtDir:(NSString *)dir
             isEndEnable:(BOOL)isEnableButton
          projectContent:(NSString *)projectContent
         projectFilePath:(NSString *)projectFilePath
          dispatch_queue:(dispatch_queue_t)queue
            withPrefixes:(NSArray *)prefixes
                progress:(void (^)(NSString *detail))progress
              completion:(void (^)(NSString *tips,BOOL isEnableButton))completion;


+ (id)excuteShellWithScript:(NSString*)shellScriptString path:(NSString *)filePath;

void deleteComments(NSString *directory);

void convertEncoding(NSString *directory);

@end
