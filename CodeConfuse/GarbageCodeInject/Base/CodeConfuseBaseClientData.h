//
//  CodeConfuseBaseClientData.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>
@class CodeConfuseBaseClientNode;

@interface CodeConfuseBaseClientData : NSObject

@property (nonatomic, copy) NSString *file;
@property (nonatomic, strong, readonly) NSData *fileData;
@property (nonatomic, strong, readonly) NSString* fileOriginContent;
@property (nonatomic, copy) NSString* replacedFileContent;

/** 所有的节点 */
@property (nonatomic, strong) NSMutableArray<CodeConfuseBaseClientNode*> *nodes;

/** 更新文本内容 */
- (BOOL)updateContent NS_REQUIRES_SUPER;

@end
