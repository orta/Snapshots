//
//  NSFileManager+RecursiveFind.h
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

@interface NSFileManager (ORRecursiveFind)

- (NSString *)or_findFileWithNamePrefix:(NSString *)name inFolder:(NSString *)folder;


@end