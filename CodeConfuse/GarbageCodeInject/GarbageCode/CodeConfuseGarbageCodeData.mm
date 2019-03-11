//
//  CodeConfuseGarbageCodeData.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "CodeConfuseGarbageCodeData.h"
#import "CodeConfuseGarbageCodeBuilder.h"
#import "CodeConfuseOCGarbageCode.h"
#import "CodeConfuseCppGarbageCode.h"
#import "CodeConfuseRandomCode.h"
#import "ConfuseCore.h"

@implementation CodeConfuseGarbageCodeData

- (instancetype)init {
    self = [super init];
//    _obfuscations = [NSMutableArray array];
    return self;
}

// 更新文本内容
- (BOOL)updateContent {
    [super updateContent];
    
    CodeConfuseOCGarbageCode *gc_oc = [[CodeConfuseOCGarbageCode alloc] init];
    CodeConfuseCppGarbageCode *gc_cpp = [[CodeConfuseCppGarbageCode alloc] init];
    
    NSString *insertOCClassContent = @"";
    NSString *insertCppClassContent = @"";
    if ([self.file hasSuffix:@".m"] || [self.file hasSuffix:@".mm"])
    {
        insertOCClassContent = [NSString stringWithFormat:@"%s",  [gc_oc generate_oc_class].c_str()];
    }
    
    if ([self.file hasSuffix:@".cpp"] || [self.file hasSuffix:@".cxx"])
    {
        insertCppClassContent = [NSString stringWithFormat:@"%s",  [gc_cpp generate_cpp_class].c_str()];
    }
    
    NSMutableData* contentData = [NSMutableData dataWithData:self.fileData];

    for (CodeConfuseGarbageCodeNode* node in self.nodes) {
        NSString* insertContent = @"";
        NSString* insertMethodEndContent = @"";
        switch (node.codeType) {
            case CXCursor_ObjCImplementationDecl:
                {
                    // OC方法体
//                    NSString* codeOString = [CodeConfuseGarbageCodeBuilder code_MethodDeclStringWithDeclMethods:@[declDataCArrM, declDataIArrM]];
//                    insertContent = codeOString;
                }
                break;
            case CXCursor_ObjCInstanceMethodDecl:
                {
                    // 随机获取实例方法的调用文本
                    uint32_t upper_bound_int = (uint32_t)gc_oc.instance_method_call_list.count;
                    if (upper_bound_int > 0)
                    {
                        NSInteger index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                        CodeConfuseMethodDeclData* declData = gc_oc.instance_method_call_list[index];
                        insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                        NSLog(@"insertContent: %@", insertContent);
                        
                        NSInteger other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                        if (other_index == index) {
                            other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                            if (other_index == index) {
                                other_index = index == 0 ? index+1 : index-1;
                            }
                        }
                        CodeConfuseMethodDeclData* other_declData = gc_oc.instance_method_call_list[other_index];
                        insertMethodEndContent = [NSString stringWithFormat:@"\n%@", other_declData.callText];
                        NSLog(@"insertMethodEndContent: %@", insertMethodEndContent);
                    }
                }
                break;
            case CXCursor_ObjCClassMethodDecl:
                {
                    // 随机获取类方法的调用文本
                    uint32_t upper_bound_int = (uint32_t)gc_oc.class_method_call_list.count;
                    if (upper_bound_int > 0)
                    {
                        NSInteger index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                        CodeConfuseMethodDeclData* declData = gc_oc.class_method_call_list[index];
                        insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                        NSLog(@"insertContent: %@", insertContent);
                        
                        NSInteger other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                        if (other_index == index) {
                            other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                            if (other_index == index) {
                                other_index = index == 0 ? index+1 : index-1;
                            }
                        }
                        CodeConfuseMethodDeclData* other_declData = gc_oc.class_method_call_list[other_index];
                        insertMethodEndContent = [NSString stringWithFormat:@"\n%@", other_declData.callText];
                        NSLog(@"insertMethodEndContent: %@", insertMethodEndContent);
                    }
                }
                break;
            case CXCursor_ObjCPropertyDecl:
                {
//                    if (self.obfuscations.count > 0) {
//                        insertContent = [CodeConfuseGarbageCodeBuilder code_randomPropertyTypeIvarWithDeclString:node.declString name:node.name randomString:self.obfuscations.lastObject];
//                        [self.obfuscations removeLastObject];
//                    } else {
//                        insertContent = @"\n// 这里是属性声明的开头\n";
//                    }
//
                }
                break;
            case CXCursor_ObjCIvarDecl:
                {
//                    if (self.obfuscations.count > 0) {
//                        insertContent = [CodeConfuseGarbageCodeBuilder code_randomPropertyTypeIvarWithDeclString:node.declString name:node.name randomString:self.obfuscations.lastObject];
//                        [self.obfuscations removeLastObject];
//                    } else {
//                        insertContent = @"\n\t// 这里是成员变量声明的开头\n";
//                    }
//
                }
                break;
            case CXCursor_FunctionDecl:
                {
                    //直接将新生成的类的声明和定义放在文件开头
                    if ([self.file hasSuffix:@".m"] || [self.file hasSuffix:@".mm"])
                    {
                        int rand_method_call = arc4random()%2000+1;
                        if (rand_method_call%2 == 0)
                        {
                            // 随机获取类方法的调用文本
                            uint32_t upper_bound_int = (uint32_t)gc_oc.class_method_call_list.count;
                            if (upper_bound_int > 0)
                            {
                                NSInteger index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                CodeConfuseMethodDeclData* declData = gc_oc.class_method_call_list[index];
                                insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                                NSLog(@"insertContent: %@", insertContent);
                                
                                NSInteger other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                if (other_index == index) {
                                    other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                    if (other_index == index) {
                                        other_index = index == 0 ? index+1 : index-1;
                                    }
                                }
                                CodeConfuseMethodDeclData* other_declData = gc_oc.class_method_call_list[other_index];
                                insertMethodEndContent = [NSString stringWithFormat:@"\n%@", other_declData.callText];
                                NSLog(@"insertMethodEndContent: %@", insertMethodEndContent);
                            }
                        }
                        else
                        {
                            // 随机获取实例方法的调用文本
                            uint32_t upper_bound_int = (uint32_t)gc_oc.instance_method_call_list.count;
                            if (upper_bound_int > 0)
                            {
                                NSInteger index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                CodeConfuseMethodDeclData* declData = gc_oc.instance_method_call_list[index];
                                insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                                NSLog(@"insertContent: %@", insertContent);
                                
                                NSInteger other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                if (other_index == index) {
                                    other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                    if (other_index == index) {
                                        other_index = index == 0 ? index+1 : index-1;
                                    }
                                }
                                CodeConfuseMethodDeclData* other_declData = gc_oc.instance_method_call_list[other_index];
                                insertMethodEndContent = [NSString stringWithFormat:@"\n%@", other_declData.callText];
                                NSLog(@"insertMethodEndContent: %@", insertMethodEndContent);
                            }
                        }
                    }
                    
                    if ([self.file hasSuffix:@".cpp"] || [self.file hasSuffix:@".cxx"])
                    {
                        // 随机获取实例方法的调用文本
                        uint32_t upper_bound_int = (uint32_t)gc_cpp.cpp_method_call_list.count;
                        if (upper_bound_int > 0)
                        {
                            NSInteger index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                            CodeConfuseMethodDeclData* declData = gc_cpp.cpp_method_call_list[index];
                            insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                            NSLog(@"insertContent: %@", insertContent);
                            
                            NSInteger other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                            if (other_index == index) {
                                other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                                if (other_index == index) {
                                    other_index = index == 0 ? index+1 : index-1;
                                }
                            }
                            CodeConfuseMethodDeclData* other_declData = gc_cpp.cpp_method_call_list[other_index];
                            insertMethodEndContent = [NSString stringWithFormat:@"\n%@", other_declData.callText];
                            NSLog(@"insertMethodEndContent: %@", insertMethodEndContent);
                        }
                    }
                }
                break;
                
            case CXCursor_CXXMethod:
                {
                    // 随机获取实例方法的调用文本
                    uint32_t upper_bound_int = (uint32_t)gc_cpp.cpp_method_call_list.count;
                    if (upper_bound_int > 0)
                    {
                        NSInteger index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                        CodeConfuseMethodDeclData* declData = gc_cpp.cpp_method_call_list[index];
                        insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                        NSLog(@"insertContent: %@", insertContent);
                        
                        NSInteger other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                        if (other_index == index) {
                            other_index = [CodeConfuseRandomCode rand_num:0 max:upper_bound_int-1];
                            if (other_index == index) {
                                other_index = index == 0 ? index+1 : index-1;
                            }
                        }
                        CodeConfuseMethodDeclData* other_declData = gc_cpp.cpp_method_call_list[other_index];
                        insertMethodEndContent = [NSString stringWithFormat:@"\n%@", other_declData.callText];
                        NSLog(@"insertMethodEndContent: %@", insertMethodEndContent);
                    }
                }
                break;
                
            default:
                insertContent = @"\n\t//垃圾代码\n";
                break;
        }
        
        // 插入
        NSData* insertData = [insertContent dataUsingEncoding:NSUTF8StringEncoding];
        if (node.methodEndOffset > 0) {
            
            NSData* insertEndData = [insertMethodEndContent dataUsingEncoding:NSUTF8StringEncoding];
            if ([ConfuseCore sharedInstance].isHighLevelConfuse) {
                [contentData replaceBytesInRange:NSMakeRange(node.methodEndOffset-1, 0) withBytes:insertEndData.bytes length:insertEndData.length];
            }
            else {
                if (insertEndData.length % 2 == 0) {
                    [contentData replaceBytesInRange:NSMakeRange(node.methodEndOffset-1, 0) withBytes:insertEndData.bytes length:insertEndData.length];
                }
            }
        }
        
        if (node.methodStartOffset > 0) {
            if ([ConfuseCore sharedInstance].isHighLevelConfuse) {
                [contentData replaceBytesInRange:NSMakeRange(node.methodStartOffset, 0) withBytes:insertData.bytes length:insertData.length];
            }
            else {
                if (insertData.length % 2 == 0) {
                    [contentData replaceBytesInRange:NSMakeRange(node.methodStartOffset, 0) withBytes:insertData.bytes length:insertData.length];
                }
            }
        }
    }
    
    NSMutableData *resultData = contentData;
    //直接将新生成的类的声明和定义放在文件开头
    if ([self.file hasSuffix:@".m"] || [self.file hasSuffix:@".mm"])
    {
        NSData* insertClassData = [insertOCClassContent dataUsingEncoding:NSUTF8StringEncoding];
        resultData = [insertClassData mutableCopy];
        [resultData appendData:contentData];
    }
    
    if ([self.file hasSuffix:@".cpp"] || [self.file hasSuffix:@".cxx"])
    {
        NSData* insertClassData = [insertCppClassContent dataUsingEncoding:NSUTF8StringEncoding];
        resultData = [insertClassData mutableCopy];
        [resultData appendData:contentData];
    }
    
    NSString *fileContent = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    // NSLog(@"%@", self.fileContent);
    
    NSError* error;
    // 覆盖文件
    NSLog(@"self.file: %@", self.file);
    [fileContent writeToFile:self.file atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    return (!!fileContent) && (!error);
}


@end
