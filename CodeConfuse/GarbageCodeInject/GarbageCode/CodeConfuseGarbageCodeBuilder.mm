//
//  CodeConfuseGarbageCodeBuilder.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "CodeConfuseGarbageCodeBuilder.h"
#import "NSArray+Extension.h"
#import "NSString+Extension.h"

@implementation CodeConfuseGarbageCodeBuilder

/** 随机生成 类方法 & 实例方法 */
+ (NSArray*)code_randomMethodWithDeclMethod:(CodeConfuseDeclMethod)declMethod {
    // 记录生成的所有方法
    NSMutableArray* declDataArrM = [NSMutableArray array];
    
    // 生成简单的随机模板方法 没有参数, 可以适当的添加参数
    CodeConfuseMethodDeclData* declData = [CodeConfuseMethodDeclData new];
    // 方法类型
    declData.declMethod = declMethod;
    
    // 方法调用
    declData.callText = @"";
    
    // 方法实现
    declData.declText = @"";
    
    // 添加
    [declDataArrM addObject:declData];
    
    return declDataArrM.copy;
}

/** 返回方法体 */
+ (NSString*)code_MethodDeclStringWithDeclMethods:(NSArray*)declMethods {
    
    NSMutableString* declMethodStringM = [NSMutableString string];
    for (NSArray* arr in declMethods) {
        for (CodeConfuseMethodDeclData* declData in arr) {
            [declMethodStringM appendString:declData.declText];
        }
    }
    
    return declMethodStringM.copy;
}

// 属性与成员变量的随机生成
+ (NSString*)code_randomPropertyTypeIvarWithDeclString:(NSString*)declString name:(NSString*)name randomString:(NSString*)randomString {
    declString = [declString stringByReplacingOccurrencesOfString:name withString:randomString options:NSBackwardsSearch range:NSMakeRange(0, declString.length)];
    declString = [NSString stringWithFormat:@"\n%@;\n", declString];
    return declString;
}

@end
