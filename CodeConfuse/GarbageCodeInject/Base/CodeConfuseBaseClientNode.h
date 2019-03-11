//
//  CodeConfuseBaseClientNode.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>

//节点
@interface CodeConfuseBaseClientNode : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger methodStartOffset;   //标记加入垃圾代码的起始位置
@property (nonatomic, assign) NSInteger methodEndOffset;     //标记加入垃圾代码的结束位置

@end
