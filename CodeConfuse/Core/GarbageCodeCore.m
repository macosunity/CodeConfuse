//
//  GarbageCodeCore.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "GarbageCodeCore.h"
#import "NSString+Extension.h"
#import "NSFileManager+Extension.h"
#import "ClangAnalyzeCore.h"
#import "NSArray+Extension.h"
#import "ConfuseCore.h"

@implementation GarbageCodeCore

+ (void)obfuscateAtDir:(NSString *)dir
                    prefixes:(NSArray *)prefixes
                    progress:(void (^)(NSString *))progress
                  completion:(void (^)(NSString *))completion
{
    if (dir.length == 0 || !completion) return;
    
    !progress ? : progress(@"正在扫描目录...");
    NSArray *subpaths = [NSFileManager code_subpathsAtPath:dir extensions:@[@"m", @"mm"]];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *subpath in subpaths) {
        !progress ? : progress([NSString stringWithFormat:@"分析：%@", subpath.lastPathComponent]);
        [set addObjectsFromArray:
         [ClangAnalyzeCore classesAndMethodsWithFile:subpath
                                            prefixes:prefixes
                                          searchPath:dir].allObjects];
    }
    
    !progress ? : progress(@"正在混淆...");
    NSMutableString *fileContent = [NSMutableString string];
    NSMutableArray *obfuscations = [NSMutableArray array];
    int index = 0;
    for (NSString *token in set) {
        NSString *obfuscation = nil;
        while (!obfuscation || [obfuscations containsObject:obfuscation]) {
            obfuscation = [NSString code_randomStringWithoutDigital];
        }
        
        [obfuscations addObject:obfuscation];
        
        [fileContent appendFormat:@"#define %@ %@", token, obfuscation];
        
        if (++index != set.count) {
            [fileContent appendString:@"\n"];
        }
    }
    
    !progress ? : progress(@"混淆完毕!");
    completion(fileContent);
}


/** 转换编码 */
+ (void)convertEncodingInDir:(NSString *)dir
              dispatch_queue:(dispatch_queue_t)queue
                    progress:(void (^)(NSString *detail))progress
                  completion:(void (^)(NSString *tips,BOOL isEnableButton))completion
{
    if (dir.length == 0) return;
    
    dispatch_async(queue, ^{
        
        !progress ? : progress(@"正在扫描目录...");
        
        convertEncoding(dir);
        
        if (completion) {
            completion(@"请选择混淆方式！", YES);
        }
    });
}

/** 垃圾代码 */
+ (void)generateCodeAtDir:(NSString *)dir
           dispatch_queue:(dispatch_queue_t)queue
                 progress:(void (^)(NSString *detail))progress
               completion:(void (^)(NSString *tips,BOOL isEnableButton))completion
{
    if (dir.length == 0) return;
    
    dispatch_async(queue, ^{
        
        !progress ? : progress(@"正在扫描目录...");
        
        deleteComments(dir);
        
        NSArray *subpaths = [NSFileManager code_subpathsAtPath:dir extensions:@[@"m", @"mm", @"cpp", @"cxx"]];
        
        // 文件原大小
        NSUInteger orgFileSize = [subpaths code_fileSize];
        
        !progress ? : progress(@"正在添加垃圾代码...");
        
        for (NSString *subpath in subpaths) {
            !progress ? : progress([NSString stringWithFormat:@"正在混淆：%@", subpath.lastPathComponent]);
            [ClangAnalyzeCore generateCodeWithFile:subpath prefixes:@[] searchPath:dir];
            !progress ? : progress([NSString stringWithFormat:@"结束混淆：%@", subpath.lastPathComponent]);
        }
        
        NSUInteger newFileSize = [subpaths code_fileSize];
        
        NSUInteger fileSize = newFileSize - orgFileSize;
        NSString* tips = [NSString stringWithFormat:@"混淆成功！共修改 %zd 个文件\n", subpaths.count];
        if (fileSize > 1024) {
            tips = [NSString stringWithFormat:@"%@修改前文件总共大小 %zd字节(%0.02fkb) \n修改后文件总共大小 %zd字节(%0.02fkb)\n成功添加 %0.02fkb 的大小", tips, orgFileSize, orgFileSize/1024.0, newFileSize, newFileSize/1024.0, fileSize/1024.0];
        } else {
            tips = [NSString stringWithFormat:@"%@修改前文件总共大小 %zd字节(%0.02fkb) \n修改后文件总共大小 %zd字节(%0.02fkb)\n成功添加 %zd字节 的大小", tips, orgFileSize, orgFileSize/1024.0, newFileSize, newFileSize/1024.0, fileSize];
        }
        
        !progress ? : progress(tips);
        
        if (completion) {
            completion(@"", YES);
        }
    });
}

@end
