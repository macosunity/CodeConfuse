//
//  ConfuseCore.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/17.
//  Copyright © 2018年 All rights reserved.
//

#import "ConfuseCore.h"
#import "NSString+Extension.h"

@implementation ConfuseCore

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)confuseCodeAtDir:(NSString *)dir
             isEndEnable:(BOOL)isEnableButton
          projectContent:(NSString *)projectContent
         projectFilePath:(NSString *)projectFilePath
          dispatch_queue:(dispatch_queue_t)queue
            withPrefixes:(NSArray *)prefixes
                progress:(void (^)(NSString *detail))progress
              completion:(void (^)(NSString *tips,BOOL isEnableButton))completion
{
    dispatch_async(queue, ^{
        NSLog(@"开始修改类名前缀...\n");
        @autoreleasepool {
            
            [ConfuseCore sharedInstance].progressBlock = ^(NSString *tip){
                progress(tip);
            };
            
            NSMutableString *mutableProjectContent = [projectContent mutableCopy];
            [ConfuseCore modifyClassNamePrefix:mutableProjectContent source:dir ignore:@[@".git",@".svn",@"Pods"] oldPrefix:prefixes[0] newPrefix:prefixes[1]];
            
            if (projectFilePath) {
                [mutableProjectContent writeToFile:projectFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
        if (completion) {
            completion(@"修改类名前缀完成", isEnableButton);
        }
        NSLog(@"修改类名前缀完成\n");
        
    });
}

+ (id)excuteShellWithScript:(NSString*)shellScriptString path:(NSString *)filePath
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";
    
    task.arguments = [NSArray arrayWithObjects:@"-c", shellScriptString, nil];
    task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    NSLog(@"Victor-Debug : \n%@",outputString);
    
    NSArray *pathArray = [outputString componentsSeparatedByString:@"\n"];
    
    NSString *projPath = @"";
    for (NSString *path in pathArray) {
        NSString *subPath = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",filePath] withString:@""];
        NSLog(@"filePath: %@", filePath);
        NSLog(@"subPath: %@", subPath);
        if (subPath.length>0 && [subPath containsString:@".xcodeproj"]) {
            projPath = subPath;
            NSLog(@"projPath: %@", projPath);
            break;
        }
    }
    
    NSString *projectPath = [NSString stringWithFormat:@"%@/%@", filePath, projPath];
    NSLog(@"projectPath: %@", projectPath);
    return projectPath;
}

+ (void)renameFile:(NSString *)oldPath  newPath:(NSString *)newPath
{
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) {
        NSLog(@"修改文件名称失败。\n  oldPath=%@\n  newPath=%@\n  ERROR:%@\n", oldPath, newPath, error.localizedDescription);
        abort();
    }
}

+ (BOOL)isDirNameContains:(NSArray<NSString *> *)ignoreDirNames inPath:(NSString *)filePath
{
    if (ignoreDirNames && [ignoreDirNames isKindOfClass:[NSArray class]] && ignoreDirNames.count > 0) {
        BOOL isContain = NO;
        for(NSString *dirName in ignoreDirNames) {
            NSLog(@"filePath:%@, dirName:%@", filePath, dirName);
            if ([filePath containsString:dirName]) {
                isContain = YES;
                break;
            }
        }
        return isContain;
    }
    
    return NO;
}

///替换类的前缀
+ (void)modifyClassNamePrefix:(NSMutableString *)projectContent source:(NSString *)sourceCodeDir ignore:(NSArray<NSString *> *)ignoreDirNames oldPrefix:(NSString *)oldName newPrefix:(NSString *)newName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [ConfuseCore sharedInstance].ignoreDirNames = ignoreDirNames;
    
    // 遍历源代码文件 h 与 m 配对，swift
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if ([ConfuseCore isDirNameContains:ignoreDirNames inPath:filePath]) {
                continue;
            }
            [ConfuseCore modifyClassNamePrefix:projectContent source:path ignore:ignoreDirNames oldPrefix:oldName newPrefix:newName];
            continue;
        }
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        NSString *fileExtension = filePath.pathExtension;
        NSString *newClassName;
        if ([fileName hasPrefix:oldName]) {
            newClassName = [newName stringByAppendingString:[fileName substringFromIndex:oldName.length]];
        } else {
            //不包含前缀的不加新前缀
            newClassName = fileName;
        }
        
        // 文件名 Const.ext > DDConst.ext
        if ([fileExtension isEqualToString:@"h"]) {
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            NSString *mmFileName = [fileName stringByAppendingPathExtension:@"mm"];
            NSString *cppFileName = [fileName stringByAppendingPathExtension:@"cpp"];
            if ([files containsObject:mFileName]) {
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"m"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"m"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
                if ([fm fileExistsAtPath:oldFilePath]) {
                    newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                    [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                }
                
                @autoreleasepool {
                    NSString *gSourceDir = [ConfuseCore sharedInstance].projectRootPath;
                    [ConfuseCore modifyFilesClassNameInDir:gSourceDir oldName:fileName newName:newClassName];
                    NSLog(@"gSourceCodeDir is: %@, fileName%@, newClassName:%@", gSourceDir, fileName, newClassName);
                }
            }
            else if([files containsObject:mmFileName]){
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"mm"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"mm"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
                if ([fm fileExistsAtPath:oldFilePath]) {
                    newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                    [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                }
                
                @autoreleasepool {
                    NSString *gSourceDir = [ConfuseCore sharedInstance].projectRootPath;
                    [ConfuseCore modifyFilesClassNameInDir:gSourceDir oldName:fileName newName:newClassName];
                    NSLog(@"gSourceCodeDir is: %@, fileName%@, newClassName:%@", gSourceDir, fileName, newClassName);
                }
            }
            else if([files containsObject:cppFileName]){
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"cpp"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"cpp"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                
                @autoreleasepool {
                    NSString *gSourceDir = [ConfuseCore sharedInstance].projectRootPath;
                    [ConfuseCore modifyFilesClassNameInDir:gSourceDir oldName:fileName newName:newClassName];
                    NSLog(@"gSourceCodeDir is: %@, fileName%@, newClassName:%@", gSourceDir, fileName, newClassName);
                }
            }
            else {
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
                @autoreleasepool {
                    NSString *gSourceDir = [ConfuseCore sharedInstance].projectRootPath;
                    [ConfuseCore modifyFilesClassNameInDir:gSourceDir oldName:fileName newName:newClassName];
                    NSLog(@"gSourceCodeDir is: %@, fileName%@, newClassName:%@", gSourceDir, fileName, newClassName);
                }
                //                continue;
            }
        } else if ([fileExtension isEqualToString:@"swift"]) {
            NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"swift"];
            NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"swift"];
            [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
            oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
            if ([fm fileExistsAtPath:oldFilePath]) {
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                [ConfuseCore renameFile:oldFilePath newPath:newFilePath];
            }
            
            @autoreleasepool {
                NSString *gSourceDir = [ConfuseCore sharedInstance].projectRootPath;
                [ConfuseCore modifyFilesClassNameInDir:gSourceDir oldName:fileName.stringByDeletingPathExtension newName:newClassName];
                NSLog(@"gSourceCodeDir is: %@, fileName%@, newClassName:%@", gSourceDir, fileName.stringByDeletingPathExtension, newClassName);
            }
        } else {
            continue;
        }
        
        if (projectContent) {
            // 修改工程文件中的文件名
            NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", fileName];
            [ConfuseCore regularReplacement:projectContent reg:regularExpression newString:newClassName];
        }
    }
}


#pragma mark - 修改类名前缀
+ (void)modifyFilesClassNameInDir:(NSString *)sourceCodeDir oldName:(NSString *)oldClassName newName:(NSString *)newClassName {
    // 文件内容 Const > DDConst (h,m,swift,xib,storyboard)
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    NSLog(@"files: %@", files);
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        
        if ([ConfuseCore isDirNameContains:[ConfuseCore sharedInstance].ignoreDirNames inPath:filePath]) {
            continue;
        }
        
        NSLog(@"curr path is: %@", path);
        ///如果路径下的是文件夹，继续往下走，知道找到一个文件
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            NSString *tipPath = path;
            tipPath = [tipPath stringByReplacingOccurrencesOfString:sourceCodeDir withString:@""];
            NSString *tip = [NSString stringWithFormat:@"正在混淆%@目录下类名%@-->%@", tipPath, oldClassName, newClassName];
            [ConfuseCore sharedInstance].progressBlock(tip);
            [ConfuseCore modifyFilesClassNameInDir:path oldName:oldClassName newName:newClassName];
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".m"] || [fileName hasSuffix:@".mm"] || [fileName hasSuffix:@".pch"] || [fileName hasSuffix:@".swift"] || [fileName hasSuffix:@".cpp"] || [fileName hasSuffix:@".xib"] || [fileName hasSuffix:@".storyboard"]) {
            NSError *error = nil;
            NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"打开文件 %@ 失败：%@\n", path, error.localizedDescription);
                abort();
            }
            
            NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldClassName];
            BOOL isChanged = [ConfuseCore regularReplacement:fileContent reg:regularExpression newString:newClassName];
            if (!isChanged) continue;
            error = nil;
            [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"保存文件 %@ 失败：%@\n", path, error.localizedDescription);
                abort();
            }
            
            [ConfuseCore replaceFileContend:[ConfuseCore sharedInstance].projectRootPath oldName:oldClassName newName:newClassName];
            NSLog(@"*** gSourceCodeDir is: %@", [ConfuseCore sharedInstance].projectRootPath);
        }
    }
}

///当修改类前缀时，将引入到的地方也遍历修改
+ (void)replaceFileContend:(NSString *)sourceCodeDir oldName:(NSString *)oldClassName newName:(NSString *)newClassName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        
        if ([ConfuseCore isDirNameContains:[ConfuseCore sharedInstance].ignoreDirNames inPath:filePath]) {
            continue;
        }
        ///如果路径下的是文件夹，继续往下走,知道找到一个文件
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            [ConfuseCore replaceFileContend:path oldName:oldClassName newName:newClassName];
            continue;
        }
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".m"] || [fileName hasSuffix:@".mm"] || [fileName hasSuffix:@".pch"] || [fileName hasSuffix:@".swift"]|| [fileName hasSuffix:@".cpp"] || [fileName hasSuffix:@".xib"] || [fileName hasSuffix:@".storyboard"]) {
            NSError *error = nil;
            NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"打开文件 %@ 失败：%@\n", path, error.localizedDescription);
                abort();
            }
            if([fileContent containsString:oldClassName]){
                NSRange range = NSMakeRange(0, fileContent.length);
                [fileContent replaceOccurrencesOfString:oldClassName withString:newClassName options:NSCaseInsensitiveSearch range:range];
            }
        }
    }
}

#pragma mark - 删除注释
void deleteComments(NSString *directory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            deleteComments(filePath);
            continue;
        }
        if (![fileName hasSuffix:@".cpp"] && ![fileName hasSuffix:@".cxx"] && ![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".mm"] && ![fileName hasSuffix:@".swift"]) {
            continue;
        }
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (fileContent == nil) {
            NSStringEncoding gbEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:gbEncoding error:nil];
        }
        NSLog(@"fileContent: %@, filePath:%@", fileContent, filePath);
        if (fileContent != nil)
        {
            [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

//转换编码
void convertEncoding(NSString *directory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            deleteComments(filePath);
            continue;
        }
        if (![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".cpp"] && ![fileName hasSuffix:@".cxx"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".mm"] && ![fileName hasSuffix:@".swift"]) continue;
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (fileContent == nil) {
            NSStringEncoding gbEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:gbEncoding error:nil];
        }
        NSLog(@"fileContent: %@, filePath:%@", fileContent, filePath);
        if (fileContent != nil)
        {
            [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}


+ (BOOL)regularReplacement:(NSMutableString *)originalString reg:(NSString *)regularExpression newString:(NSString *)newString
{
    __block BOOL isChanged = NO;
    BOOL isGroupNo1 = [newString isEqualToString:@"\\1"];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnixLineSeparators error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isChanged) {
            isChanged = YES;
        }
        if (isGroupNo1) {
            NSString *withString = [originalString substringWithRange:[obj rangeAtIndex:1]];
            [originalString replaceCharactersInRange:obj.range withString:withString];
        } else {
            [originalString replaceCharactersInRange:obj.range withString:newString];
        }
    }];
    return isChanged;
}
@end
