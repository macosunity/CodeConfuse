//
//  CustomMarqueeLabel.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/27.
//  Copyright © 2018年 All rights reserved.
//

#import "CustomMarqueeLabel.h"

#define YCenterLabel(label, view, x) \
    label.frame = NSMakeRect(x, (NSHeight(view.frame)-NSHeight(label.frame))/2.0,NSWidth(label.frame), NSHeight(label.frame))

@implementation CustomMarqueeLabel

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [NSColor clearColor];
        [self _setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code here.
        [self _setup];
    }
    
    return self;
}

- (void)dealloc
{
    if(timer) [timer invalidate]; timer = nil;
}


- (void)_createMarqueeLabels
{
    NSTextField* (^CreateTextFieldCopy)(NSTextField *) = ^ NSTextField *(NSTextField* dest) {
        NSTextField *textField = [[NSTextField alloc]initWithFrame:NSZeroRect];
        [textField setEditable:NO];
        [textField setBordered:NO];
        [textField setDrawsBackground:NO];
        [textField setBackgroundColor:[NSColor clearColor]];
        
        textField.textColor = dest.textColor;
        textField.stringValue = dest.stringValue;
        textField.font = dest.font;
        
        [textField sizeToFit];
        return textField;
    };
        
    NSTextField *label1 = CreateTextFieldCopy(self);
    NSTextField *label2 = CreateTextFieldCopy(self);
    
    flag = 0;
    YCenterLabel(label1, self, 10);
    YCenterLabel(label2, self, NSWidth(self.frame)+10);
    
    
    labels[0] = label1;
    labels[1] = label2;
    
    [super setStringValue:@""];
}

- (void)_setupMarqueeLabel
{
    NSDictionary *att = [NSDictionary dictionaryWithObject:self.font forKey:NSFontAttributeName];
    NSSize textSize = [self.stringValue sizeWithAttributes:att];
    
    if(timer) [timer invalidate]; timer = nil;
    
    if(textSize.width > NSWidth(self.bounds) - 10)
    {
        [self _createMarqueeLabels];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self
                                               selector:@selector(updatePosition)
                                               userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    else
    {
        labels[0] = nil;
        labels[1] = nil;
        
        [self setNeedsDisplay];
    }
}

- (void)_setup
{
    [self _setupMarqueeLabel];
}

- (void)setStringValue:(NSString *)aString
{
    [super setStringValue:aString];
    [self _setupMarqueeLabel];
}

- (void)updatePosition
{
    NSTextField *label = labels[flag];
    
    [label setFrameOrigin:NSMakePoint(NSMinX(label.frame)-0.5, NSMinY(label.frame))];
    
    if(NSMaxX(label.frame) < NSWidth(self.frame)*0.8)  {
        [labels[flag?0:1] setFrameOrigin:NSMakePoint(NSMinX(labels[flag?0:1].frame)-0.5, NSMinY(labels[flag?0:1].frame))];
    }

    if(NSMaxX(label.frame) < 0) {
        YCenterLabel(label, self, NSWidth(self.frame)+10);
        flag = flag?0:1;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if(labels[0] && labels[1]) {
        NSDictionary *att1 = [NSDictionary dictionaryWithObjectsAndKeys:
                             labels[0].textColor, NSForegroundColorAttributeName,
                             labels[0].font, NSFontAttributeName,nil];
        [labels[0].stringValue drawInRect:[labels[0] frame] withAttributes:att1];
        
        NSDictionary *att2 = [NSDictionary dictionaryWithObjectsAndKeys:
                              labels[1].textColor, NSForegroundColorAttributeName,
                              labels[1].font, NSFontAttributeName,nil];
        [labels[1].stringValue drawInRect:[labels[1] frame] withAttributes:att2];
    }
}

- (void)viewWillStartLiveResize
{
    if(labels[0]) [super setStringValue:labels[0].stringValue];
}

- (void)viewDidEndLiveResize
{
    [self _setupMarqueeLabel];
}

@end
