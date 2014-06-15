//
//  ORLogReader.h
//  SnapshotDiffs
//
//  Created by Orta on 6/12/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORTestsSuiteModels.h"

@interface ORLogReader : NSObject

- (NSArray *)uniqueDiffCommands;
- (NSArray *)ksdiffCommands;
- (NSString *)log;
- (BOOL)hasSnapshotTestErrors;
- (void)erase;

@end
