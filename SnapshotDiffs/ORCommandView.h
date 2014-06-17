//
//  ORCommandView.h
//  SnapshotDiffs
//
//  Created by Orta on 6/13/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORTableViewRowView.h"

@class ORKaleidoscopeCommand;

@interface ORCommandView : ORTableViewRowView

@property (weak) IBOutlet NSImageView *fromImageView;
@property (weak) IBOutlet NSImageView *toImageView;

- (void)prepareWithCommand:(ORKaleidoscopeCommand *)command;

@end
