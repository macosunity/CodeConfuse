//
//  CodeConfuseGarbageCodeBuilder.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeConfuseMethodDeclData.h"

/**
 垃圾代码生成器
 */
@interface CodeConfuseGarbageCodeBuilder : NSObject

/** 随机生成 类方法 & 实例方法 */
+ (NSArray*)code_randomMethodWithDeclMethod:(CodeConfuseDeclMethod)declMethod;

/** 返回方法体 */
+ (NSString*)code_MethodDeclStringWithDeclMethods:(NSArray*)declMethods;

/** 属性与成员变量的随机生成 */
+ (NSString*)code_randomPropertyTypeIvarWithDeclString:(NSString*)declString name:(NSString*)name randomString:(NSString*)randomString;

@end
