//
//  CodeConfuseViewController.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/17.
//  Copyright © 2018年 All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, ConfuseType) {
    ConfuseTypeClassName = 1,
    ConfuseTypeCodeInjection,
    ConfuseTypeNone,
};

@interface CodeConfuseViewController : NSViewController

@end
