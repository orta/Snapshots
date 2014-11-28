//
//  ARLabel.m
//  Snapshots
//
//  Created by Orta on 28/11/2014.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ARLabel.h"

@interface ARLabelCell : NSTextFieldCell

@end


@implementation ARLabelCell

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
    NSRectFill(rect);
}


@end

@implementation ARLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (!self) return nil;

    [self setup];
    return self;
}

- (void)setup
{
    self.bezeled         = NO;
    self.editable        = NO;
    self.drawsBackground = NO;
    self.refusesFirstResponder = YES;
//    self.wantsLayer      = YES;
//    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.backgroundColor = [NSColor clearColor];

    [(NSTextFieldCell *)self.cell setBackgroundColor:[NSColor clearColor]];
    [(NSTextFieldCell *)self.cell setDrawsBackground:NO];
}


@end
