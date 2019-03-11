//
//  CodeConfuseMethodDeclData.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/20
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>

// 类的类型定义: class & instance
typedef NS_ENUM(NSInteger, CodeConfuseDeclMethod) {
    CodeConfuseDeclMethodClass,
    CodeConfuseDeclMethodInstance
};

/** 垃圾代码节点 */
@interface CodeConfuseMethodDeclData : NSObject
/** CodeConfuseDeclMethod */
@property (nonatomic, assign) CodeConfuseDeclMethod declMethod;
/** 调用文本*/
@property (nonatomic, copy) NSString* callText;
/** 实现文本 */
@property (nonatomic, copy) NSString* declText;
@end
