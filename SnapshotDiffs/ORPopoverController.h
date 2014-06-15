//
//  ORPopoverController.h
//  SnapshotDiffs
//
//  Created by Orta on 6/13/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORLogReader;
@interface ORPopoverController : NSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil reader:(ORLogReader *)reader;

@end
