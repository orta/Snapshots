//
//  ORNewSnapshotView.h
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORTableViewRowView.h"

@class ORSnapshotCreationReference;

@interface ORNewSnapshotView : ORTableViewRowView

@property (weak) IBOutlet NSImageView *imageView;

- (void)prepareWithCommand:(ORSnapshotCreationReference *)command;

@end
