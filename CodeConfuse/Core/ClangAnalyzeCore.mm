//
//  ClangAnalyzeCore.m
//  CodeConfuseCodeObfuscation
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "ClangAnalyzeCore.h"
#import "Index.h"
#import "NSFileManager+Extension.h"
#import "NSString+Extension.h"
#import "CodeConfuseGarbageCodeData.h"
#import "CodeConfuseRandomCode.h"

/** 类名、方法名 */
@interface CodeConfuseTokensClientData : NSObject
@property (nonatomic, strong) NSArray *prefixes;
@property (nonatomic, strong) NSMutableSet *tokens;
@property (nonatomic, copy) NSString *file;
@end

@implementation CodeConfuseTokensClientData
@end

/** 字符串 */
@interface CodeConfuseStringsClientData : NSObject
@property (nonatomic, strong) NSMutableSet *strings;
@property (nonatomic, copy) NSString *file;
@end

@implementation CodeConfuseStringsClientData
@end

@implementation ClangAnalyzeCore

static const char *_getFilename(CXCursor cursor) {
    CXSourceRange range = clang_getCursorExtent(cursor);
    CXSourceLocation location = clang_getRangeStart(range);
    CXFile file;
    clang_getFileLocation(location, &file, NULL, NULL, NULL);
    return clang_getCString(clang_getFileName(file));
}

static const char *_getCursorName(CXCursor cursor) {
    return clang_getCString(clang_getCursorSpelling(cursor));
}

static bool _isFromFile(const char *filepath, CXCursor cursor) {
    if (filepath == NULL) return 0;
    const char *cursorPath = _getFilename(cursor);
    if (cursorPath == NULL) return 0;
    return strstr(cursorPath, filepath) != NULL;
}

enum CXChildVisitResult _visitTokens(CXCursor cursor,
                                      CXCursor parent,
                                      CXClientData clientData) {
    if (clientData == NULL) return CXChildVisit_Break;
    
    CodeConfuseTokensClientData *data = (__bridge CodeConfuseTokensClientData *)clientData;
    if (!_isFromFile(data.file.UTF8String, cursor)) return CXChildVisit_Continue;
    
    if (cursor.kind == CXCursor_ObjCInstanceMethodDecl ||
        cursor.kind == CXCursor_ObjCClassMethodDecl ||
        cursor.kind == CXCursor_ObjCImplementationDecl) {
        NSString *name = [NSString stringWithUTF8String:_getCursorName(cursor)];
        NSArray *tokens = [name componentsSeparatedByString:@":"];
        
        // 前缀过滤
        for (NSString *token in tokens) {
            for (NSString *prefix in data.prefixes) {
                if ([token rangeOfString:prefix].location == 0) {
                    [data.tokens addObject:token];
                }
            }
        }
    }
    
    return CXChildVisit_Recurse;
}

// 垃圾代码
enum CXChildVisitResult _visitGarbageCodes(CXCursor cursor,CXCursor parent,CXClientData clientData) {
    
    if (clientData == NULL) return CXChildVisit_Break;
    
    CodeConfuseGarbageCodeData *data = (__bridge CodeConfuseGarbageCodeData *)clientData;
    if (!_isFromFile(data.file.UTF8String, cursor)) return CXChildVisit_Continue;
    
    if (cursor.kind == CXCursor_ObjCCategoryImplDecl) {
        NSString *name = [NSString stringWithUTF8String:_getCursorName(cursor)];
        NSLog(@"发现category：%@", name);
        return CXChildVisit_Break;
    }
    
    // 仅仅是这些种类的节点才进行垃圾代码处理
    if (cursor.kind == CXCursor_ObjCImplementationDecl ||
        cursor.kind == CXCursor_ObjCInstanceMethodDecl ||
        cursor.kind == CXCursor_ObjCClassMethodDecl ||
        cursor.kind ==  CXCursor_ObjCPropertyDecl ||
        cursor.kind == CXCursor_ObjCIvarDecl ||
        cursor.kind == CXCursor_ClassDecl ||
        cursor.kind == CXCursor_FunctionDecl ||
        cursor.kind == CXCursor_CXXMethod) {
        
        NSString *name = [NSString stringWithUTF8String:_getCursorName(cursor)];
        // 为了找到插入代码的那一行
        CXSourceRange range = clang_getCursorExtent(cursor);
        CXSourceLocation startLocation = clang_getRangeStart(range);
        CXSourceLocation endLocation = clang_getRangeEnd(range);
        
        // 偏移量
        unsigned startOffset;
        unsigned endOffset;
        clang_getFileLocation(startLocation, NULL, NULL, NULL, &startOffset);
        clang_getSpellingLocation(endLocation, NULL, NULL, NULL, &endOffset);
        // 当前节点的内容描述
        NSData* fileData = [data.fileData subdataWithRange:NSMakeRange(startOffset, endOffset-startOffset)];
        NSString* declString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        
        // 节点
        CodeConfuseGarbageCodeNode* node = [CodeConfuseGarbageCodeNode new];
        
        //C++类名
        if (cursor.kind == CXCursor_ClassDecl) {
            NSLog(@"发现 C++ name: %@", name);
            
            node.codeType = CXCursor_ClassDecl;
        }
        
        if (cursor.kind == CXCursor_FunctionDecl) {
            NSLog(@"发现 function: %@", name);
            node.codeType = CXCursor_FunctionDecl;
            NSLog(@"declString: %@",  declString);
            
            if ([declString containsString:@" _cmd"])
            {
                return CXChildVisit_Break;
            }
            
            bool isTypedef = [declString rangeOfString:@"typedef "].location != NSNotFound;
            
            // 会找到 { 第一次出现的位置
            NSRange methodRangeStart = [fileData rangeOfData:[@"{" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, fileData.length)];
            NSRange methodRangeEnd = [fileData rangeOfData:[@"}" dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range:NSMakeRange(0, fileData.length)];
            if (methodRangeStart.location != NSNotFound && !isTypedef) {
                node.methodStartOffset = (unsigned)(startOffset+methodRangeStart.location+methodRangeStart.length);
                NSLog(@"node.methodStartOffset: %lu", node.methodStartOffset);
                
                //有return语句的情况
                NSMutableArray *lines = [[declString componentsSeparatedByString:@"\n"] mutableCopy];
                for (NSUInteger i=0; i<lines.count; i++) {
                    NSString *line = lines[i];
                    NSString *trimLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (trimLine.length <= 1) {
                        [lines removeObjectAtIndex:i];
                    }
                }
                
                for (NSUInteger i=0; i<lines.count; i++) {
                    NSLog(@"line: [%@]", lines[i]);
                }
                
                BOOL hasIfBeforeReturn = NO; //针对if后面直接跟return语句，没有加大括号{}包裹的情况
                if (lines.count >= 2) {
                    NSLog(@"%@", lines[lines.count-2]);
                    NSString *preLine = lines[lines.count-2];
                    preLine = [preLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    preLine = [preLine stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if (([preLine containsString:@"if("] ||
                         [preLine isEqualToString:@"else"] ||
                         [preLine containsString:@"}else"]) &&
                        ![preLine containsString:@"{"]) {
                        hasIfBeforeReturn = YES;
                    }
                }
                
                NSString *lastTrimLine = [[lines lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (([[lines lastObject] containsString:@"return "] ||
                     [[lines lastObject] containsString:@"return;"]) &&
                     !hasIfBeforeReturn &&
                     ![lastTrimLine hasPrefix:@"//"]) {
                    
                    NSString *matchReturn = @"return ";
                    if ([[lines lastObject] containsString:@"return "])
                    {
                        matchReturn = @"return ";
                    }
                    
                    if ([[lines lastObject] containsString:@"return;"])
                    {
                        matchReturn = @"return;";
                    }
                    methodRangeEnd = [fileData rangeOfData:[matchReturn dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range:NSMakeRange(0, fileData.length)];
                    if (methodRangeEnd.location != NSNotFound) {
                        node.methodEndOffset = node.methodStartOffset+(methodRangeEnd.location-methodRangeStart.location);
                    }
                    else {
                        node.methodEndOffset = 0;
                    }
                }
                else {
                    node.methodEndOffset = node.methodStartOffset+(methodRangeEnd.location-methodRangeStart.location);
                }
                NSLog(@"methodRangeStart.location: %lu", methodRangeStart.location);
                NSLog(@"methodRangeStart.length: %lu", methodRangeStart.length);
                NSLog(@"methodRangeEnd.location: %lu", methodRangeEnd.location);
                NSLog(@"node.methodEndOffset: %lu", node.methodEndOffset);
                node.codeType = CXCursor_FunctionDecl;
            }
        }
        
        if (cursor.kind == CXCursor_CXXMethod) {
            NSLog(@"发现 C++ class method: %@", name);
            node.codeType = CXCursor_CXXMethod;
            NSLog(@"declString: %@",  declString);
            // 会找到 { 第一次出现的位置
            NSRange methodRangeStart = [fileData rangeOfData:[@"{" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, fileData.length)];
            NSRange methodRangeEnd = [fileData rangeOfData:[@"}" dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range:NSMakeRange(0, fileData.length)];
            if (methodRangeStart.location != NSNotFound) {
                node.methodStartOffset = (unsigned)(startOffset+methodRangeStart.location+methodRangeStart.length);
                NSLog(@"node.methodStartOffset: %lu", node.methodStartOffset);
               
                //有return语句的情况
                NSMutableArray *lines = [[declString componentsSeparatedByString:@"\n"] mutableCopy];
                for (NSUInteger i=0; i<lines.count; i++) {
                    NSString *line = lines[i];
                    
                    if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 1) {
                        [lines removeObjectAtIndex:i];
                    }
                }
                
                for (NSUInteger i=0; i<lines.count; i++) {
                    NSLog(@"line: [%@]", lines[i]);
                }
                
                BOOL hasIfBeforeReturn = NO; //针对if后面直接跟return语句，没有加大括号{}包裹的情况
                if (lines.count >= 2) {
                    NSLog(@"%@", lines[lines.count-2]);
                    NSString *preLine = lines[lines.count-2];
                    preLine = [preLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    preLine = [preLine stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if (([preLine containsString:@"if("] ||
                         [preLine isEqualToString:@"else"] ||
                         [preLine containsString:@"}else"]) &&
                        ![preLine containsString:@"{"]) {
                        hasIfBeforeReturn = YES;
                    }
                }
                
                NSString *lastTrimLine = [[lines lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (([[lines lastObject] containsString:@"return "] ||
                     [[lines lastObject] containsString:@"return;"]) &&
                     !hasIfBeforeReturn &&
                     ![lastTrimLine hasPrefix:@"//"]) {

                    NSString *matchReturn = @"return ";
                    if ([[lines lastObject] containsString:@"return "])
                    {
                        matchReturn = @"return ";
                    }
                    
                    if ([[lines lastObject] containsString:@"return;"])
                    {
                        matchReturn = @"return;";
                    }
                    methodRangeEnd = [fileData rangeOfData:[matchReturn dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range:NSMakeRange(0, fileData.length)];
                    if (methodRangeEnd.location != NSNotFound) {
                        node.methodEndOffset = node.methodStartOffset+(methodRangeEnd.location-methodRangeStart.location);
                    }
                    else {
                        node.methodEndOffset = 0;
                    }
                }
                else {
                    node.methodEndOffset = node.methodStartOffset+(methodRangeEnd.location-methodRangeStart.location);
                }
                NSLog(@"methodRangeStart.location: %lu", methodRangeStart.location);
                NSLog(@"methodRangeStart.length: %lu", methodRangeStart.length);
                NSLog(@"methodRangeEnd.location: %lu", methodRangeEnd.location);
                NSLog(@"node.methodEndOffset: %lu", node.methodEndOffset);
                node.codeType = CXCursor_CXXMethod;
            }
        }
        
        if (cursor.kind == CXCursor_ObjCImplementationDecl) {
            // 会找到 name 第一次出现的位置
            NSRange implDeclRang = [declString rangeOfString:name];
            // 在 startOffset ~ startOffset+implDeclRang.location+implDeclRang.length; 的这个区间不可能出现非英文字符
            // 所以正确的位置就是: startOffset+implDeclRang.location+implDeclRang.length;
            node.methodStartOffset = (unsigned)(startOffset+implDeclRang.location+implDeclRang.length);
            node.codeType = CXCursor_ObjCImplementationDecl;
        } else if (cursor.kind == CXCursor_ObjCInstanceMethodDecl || cursor.kind == CXCursor_ObjCClassMethodDecl) {
            // 会找到 { 第一次出现的位置
            NSRange methodRangeStart = [fileData rangeOfData:[@"{" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, fileData.length)];
            NSRange methodRangeEnd = [fileData rangeOfData:[@"}" dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range:NSMakeRange(0, fileData.length)];
            if (methodRangeStart.location != NSNotFound) {
                node.methodStartOffset = (unsigned)(startOffset+methodRangeStart.location+methodRangeStart.length);
                node.codeType = (cursor.kind == CXCursor_ObjCInstanceMethodDecl)?CXCursor_ObjCInstanceMethodDecl:CXCursor_ObjCClassMethodDecl;
                
                //有return语句的情况
                NSMutableArray *lines = [[declString componentsSeparatedByString:@"\n"] mutableCopy];
                for (NSUInteger i=0; i<lines.count; i++) {
                    NSString *line = lines[i];
                    
                    if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 1) {
                        [lines removeObjectAtIndex:i];
                    }
                }
                
                for (NSUInteger i=0; i<lines.count; i++) {
                    NSLog(@"line: [%@]", lines[i]);
                }
                
                BOOL hasIfBeforeReturn = NO; //针对if后面直接跟return语句，没有加大括号{}包裹的情况
                if (lines.count >= 2) {
                    NSLog(@"%@", lines[lines.count-2]);
                    NSString *preLine = lines[lines.count-2];
                    preLine = [preLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    preLine = [preLine stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if (([preLine containsString:@"if("] ||
                         [preLine isEqualToString:@"else"] ||
                         [preLine containsString:@"}else"]) &&
                        ![preLine containsString:@"{"]) {
                        hasIfBeforeReturn = YES;
                    }
                }
                
                NSString *lastTrimLine = [[lines lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (([[lines lastObject] containsString:@"return "] ||
                     [[lines lastObject] containsString:@"return;"]) &&
                     !hasIfBeforeReturn &&
                     ![lastTrimLine hasPrefix:@"//"]) {
                    
                    NSString *matchReturn = @"return ";
                    if ([[lines lastObject] containsString:@"return "])
                    {
                        matchReturn = @"return ";
                    }
                    
                    if ([[lines lastObject] containsString:@"return;"])
                    {
                        matchReturn = @"return;";
                    }
                    methodRangeEnd = [fileData rangeOfData:[matchReturn dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range:NSMakeRange(0, fileData.length)];
                    if (methodRangeEnd.location != NSNotFound) {
                        node.methodEndOffset = node.methodStartOffset+(methodRangeEnd.location-methodRangeStart.location);
                    }
                    else {
                        node.methodEndOffset = 0;
                    }
                }
                else {
                    node.methodEndOffset = node.methodStartOffset+(methodRangeEnd.location-methodRangeStart.location);
                }
            }
        } else if (cursor.kind ==  CXCursor_ObjCPropertyDecl || cursor.kind == CXCursor_ObjCIvarDecl) {
            fileData = [data.fileData subdataWithRange:NSMakeRange(startOffset, data.fileData.length-startOffset)];
            NSString* declString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            
            // 会找到 ; 第一次出现的位置
            NSRange maohaoRang = [fileData rangeOfData:[@";" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, fileData.length)];
            node.methodStartOffset = (unsigned)(startOffset+maohaoRang.location+maohaoRang.length);
            node.codeType = (cursor.kind ==  CXCursor_ObjCPropertyDecl)?CXCursor_ObjCPropertyDecl:CXCursor_ObjCIvarDecl;
            
            { // 上面的 declString 主要是为了找到对应的 ;, 接下来的主要是为了记录
                fileData = [data.fileData subdataWithRange:NSMakeRange(startOffset, endOffset-startOffset)];
                declString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                node.declString = declString;
            }
        }
        
#warning Objective C
        if ((node.methodStartOffset != NSNotFound) || !name) {
            node.name = name;
            [data.nodes addObject:node];
            
//            // 每个成员变量与属性对应一个垃圾节点
//            if ((node.codeType == CXCursor_ObjCPropertyDecl) || (node.codeType == CXCursor_ObjCIvarDecl)) {
//                NSString* obfuscation = nil;
//                while (!obfuscation || [data.obfuscations containsObject:obfuscation]) {
//                    obfuscation = [NSString stringWithFormat:@"%s", [CodeConfuseRandomCode rand_string:6 max:18].c_str()];
//                }
//                [data.obfuscations addObject:obfuscation];
//            }
        }
    }
    
    return CXChildVisit_Recurse;
}

+ (NSSet *)classesAndMethodsWithFile:(NSString *)file
                            prefixes:(NSArray *)prefixes
                          searchPath:(NSString *)searchPath
{
    CodeConfuseTokensClientData *data = [[CodeConfuseTokensClientData alloc] init];
    data.file = file;
    data.prefixes = prefixes;
    data.tokens = [NSMutableSet set];
    [self _visitASTWithFile:file
                 searchPath:searchPath
                    visitor:_visitTokens
                 clientData:(__bridge void *)data];
    return data.tokens;
}

/** 生成垃圾代码 */
+ (BOOL)generateCodeWithFile:(NSString *)file
                prefixes:(NSArray *)prefixes
              searchPath:(NSString *)searchPath {
    CodeConfuseGarbageCodeData* data = [CodeConfuseGarbageCodeData new];
    data.file = file;
    data.prefixes = prefixes;
    data.nodes = [NSMutableArray array];
    [self _visitASTWithFile:file
                 searchPath:searchPath
                    visitor:_visitGarbageCodes
                 clientData:(__bridge void *)data];
    
    return [data updateContent];
}

/** 遍历某个文件的语法树 */
+ (void)_visitASTWithFile:(NSString *)file
               searchPath:(NSString *)searchPath
                  visitor:(CXCursorVisitor)visitor
               clientData:(CXClientData)clientData
{
    if (file.length == 0) return;
    
    // 文件路径
    const char *filepath = file.UTF8String;
    
    // 创建index
    CXIndex index = clang_createIndex(1, 1);
    
    // 搜索路径
    int argCount = 5;
    NSArray *subDirs = nil;
    if (searchPath.length) {
        subDirs = [NSFileManager code_subdirsAtPath:searchPath];
        argCount += ((int)subDirs.count + 1) * 2;
    }
    
    int argIndex = 0;
    const char **args = (const char **)malloc(sizeof(char *) * argCount);
    args[argIndex++] = "-c";
    args[argIndex++] = "-arch";
    args[argIndex++] = "i386";
    args[argIndex++] = "-isysroot";
    args[argIndex++] = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk";
    if (searchPath.length) {
        args[argIndex++] = "-I";
        args[argIndex++] = searchPath.UTF8String;
    }
    for (NSString *subDir in subDirs) {
        args[argIndex++] = "-I";
        args[argIndex++] = subDir.UTF8String;
    }
    
    // 解析语法树，返回根节点TranslationUnit
    CXTranslationUnit tu = clang_parseTranslationUnit(index, filepath,
                                                      args,
                                                      argCount,
                                                      NULL, 0, CXTranslationUnit_None);
    free(args);
    
    if (!tu) return;
    
    // 解析语法树
    clang_visitChildren(clang_getTranslationUnitCursor(tu),
                        visitor, clientData);
    
    // 销毁
    clang_disposeTranslationUnit(tu);
    clang_disposeIndex(index);
}

@end
