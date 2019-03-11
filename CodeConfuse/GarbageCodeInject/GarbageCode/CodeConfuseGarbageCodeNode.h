//
//  CodeConfuseGarbageCodeNode.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "CodeConfuseBaseClientNode.h"
#import "Index.h"

/** 垃圾代码节点类 */
@interface CodeConfuseGarbageCodeNode : CodeConfuseBaseClientNode

//解析出的类名
@property (nonatomic, copy) NSString *className;

//解析出来的代码类型
@property (nonatomic, assign) enum CXCursorKind codeType;

//存放解析出的代码片段
@property (nonatomic, copy) NSString* declString;

@end
