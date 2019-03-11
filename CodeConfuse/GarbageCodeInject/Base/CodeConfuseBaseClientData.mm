//
//  CodeConfuseBaseClientData.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "CodeConfuseBaseClientData.h"

@implementation CodeConfuseBaseClientData

- (void)setFile:(NSString *)file {
    _file = file.copy;
    
    _fileData = [NSData dataWithContentsOfFile:_file];
    
    NSError *error = nil;
    _fileOriginContent = [NSString stringWithContentsOfFile:_file encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"%@", [error userInfo]);
    }
}

/** 更新文本内容 */
- (BOOL)updateContent {
    
    if (self.nodes.count == 0) {
        return YES;
    }
    
    // 降序排列
    NSSortDescriptor* sortOffset = [NSSortDescriptor sortDescriptorWithKey:@"methodStartOffset" ascending:NO];
    NSArray* nodes = [self.nodes sortedArrayUsingDescriptors:@[sortOffset]];
    // 替换
    self.nodes = nodes.mutableCopy;
    
    return YES;
}

@end
