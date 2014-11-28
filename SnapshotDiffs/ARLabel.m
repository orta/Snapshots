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

- (BOOL)allowsVibrancy
{
    return NO;
}

- (void)setup
{
    self.bezeled         = NO;
    self.editable        = NO;
    self.drawsBackground = NO;
}


@end
