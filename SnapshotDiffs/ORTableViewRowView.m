//
//  ORTableViewRowView.m
//  SnapshotDiffs
//
//  Created by Orta on 6/17/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORTableViewRowView.h"

@implementation ORTableViewRowView

- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleLight;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay:YES];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    if (!self.selected) {
        CGContextSetFillColorWithColor(context, [NSColor clearColor].CGColor);
    }else{
        CGContextSetFillColorWithColor(context, [NSColor colorWithCalibratedWhite:0.750 alpha:1.000].CGColor);
    }
    
    CGContextFillRect(context, dirtyRect);
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect;
{
    
}

-(void)drawBackgroundInRect:(NSRect)dirtyRect
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    if (!self.selected) {
        CGContextSetFillColorWithColor(context, [NSColor clearColor].CGColor);
    }else{
        CGContextSetFillColorWithColor(context, [NSColor redColor].CGColor);
    }
    
    CGContextFillRect(context, dirtyRect);
}


@end
