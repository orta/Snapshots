//
//  ORPopoverTableDataSource.h
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import "ORLogReader.h"

@interface ORPopoverTableDataSource : NSObject <NSTableViewDataSource>

- (instancetype)initWithReader:(ORLogReader *)reader;
- (id)objectForRow:(NSInteger)row;


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row;
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;

@end
