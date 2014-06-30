//
//  ORNewSnapshotView.m
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORNewSnapshotView.h"
#import "ORTestsSuiteModels.h"

@implementation ORNewSnapshotView

- (void)prepareWithCommand:(ORSnapshotCreationReference *)command
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:command.path];
    self.imageView.image = image;
}

@end
