//
//  ORCommandView.h
//  SnapshotDiffs
//
//  Created by Orta on 6/13/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORKaleidoscopeCommand;
@interface ORCommandView : NSView

@property (weak) IBOutlet NSImageView *fromImageView;
@property (weak) IBOutlet NSImageView *toImageView;

@property (weak) IBOutlet NSButton *runSingleCommand;
@property (weak) ORKaleidoscopeCommand *command;

@end
