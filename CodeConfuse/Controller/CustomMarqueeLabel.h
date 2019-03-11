//
//  CustomMarqueeLabel.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/27.
//  Copyright © 2018年 All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomMarqueeLabel : NSTextField {
@private
    NSTextField *labels[2];
    NSTimer     *timer;
    int         flag;
}

@end
