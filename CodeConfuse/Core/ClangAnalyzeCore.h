//
//  ClangAnalyzeCore.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClangAnalyzeCore : NSObject

/** 获得file中的所有类名、方法名） */
+ (NSSet *)classesAndMethodsWithFile:(NSString *)file
                            prefixes:(NSArray *)prefixes
                          searchPath:(NSString *)searchPath;

/** 垃圾代码 */
+ (BOOL)generateCodeWithFile:(NSString *)file
                prefixes:(NSArray *)prefixes
              searchPath:(NSString *)searchPath;

@end
