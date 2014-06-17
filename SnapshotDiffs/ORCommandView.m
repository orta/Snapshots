//
//  ORCommandView.m
//  SnapshotDiffs
//
//  Created by Orta on 6/13/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORCommandView.h"
#import "ORLogReader.h"
#import "NSColor+ORSnapshotColours.h"

@implementation ORCommandView

- (void)prepareWithCommand:(ORKaleidoscopeCommand *)command
{    
    NSImage *before = [[NSImage alloc] initWithContentsOfFile:command.beforePath];
    NSImage *to = [[NSImage alloc] initWithContentsOfFile:command.afterPath];
    
    self.fromImageView.imageFrameStyle = NSImageFrameNone;
    self.toImageView.imageFrameStyle = NSImageFrameNone;
    
    self.fromImageView.layer.borderWidth = 1;
    self.toImageView.layer.borderWidth = 1;
    
    self.fromImageView.layer.borderColor = [NSColor or_greenColour].CGColor;
    self.toImageView.layer.borderColor = [NSColor or_redColour].CGColor;
    
    self.fromImageView.image = before;
    self.toImageView.image = to;
}

@end
