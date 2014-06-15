//
//  ORCommandView.m
//  SnapshotDiffs
//
//  Created by Orta on 6/13/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORCommandView.h"
#import "ORLogReader.h"

@implementation ORCommandView

// YOLOViewOkay

- (IBAction)openCommand:(id)sender
{
    [self.command launch];
}

@end
