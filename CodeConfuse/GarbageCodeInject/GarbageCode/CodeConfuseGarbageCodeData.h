//
//  CodeConfuseGarbageCodeData.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import "CodeConfuseBaseClientData.h"
#import "CodeConfuseGarbageCodeNode.h"

/** 垃圾代码 */
@interface CodeConfuseGarbageCodeData : CodeConfuseBaseClientData

@property (nonatomic, strong) NSArray *prefixes;

//@property (nonatomic, strong) NSMutableArray* obfuscations;

@end
