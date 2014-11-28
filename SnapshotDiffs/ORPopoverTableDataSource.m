//
//  ORPopoverTableDataSource.m
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORPopoverTableDataSource.h"
#import "ORTestsSuiteModels.h"
#import "ORCommandView.h"
#import "ORTestCaseTitleView.h"
#import "ORNewSnapshotView.h"
#import "ORLogReader.h"

@interface ORPopoverTableDataSource ()

@property (nonatomic, readonly) ORLogReader *reader;
@property (nonatomic, strong) NSArray *flattenedData;
@end

@implementation ORPopoverTableDataSource

- (instancetype)initWithReader:(ORLogReader *)reader;
{
    self = [super init];
    if (!self) return nil;
    
    _reader = reader;
    _flattenedData = [self flattenedReaderData:reader];
    
    return self;
}

- (NSArray *)flattenedReaderData:(ORLogReader *)reader
{
    NSMutableArray *data = [NSMutableArray array];
    for (ORTestSuite *suite in self.reader.testSuites) {
        if (suite.hasFailingTests || suite.hasNewSnapshots) {
            [data addObject:suite.name];
            
            for (ORTestCase *testCase in suite.testCases) {
                [data addObjectsFromArray:testCase.uniqueDiffCommands];
                [data addObjectsFromArray:testCase.snapshots];
            }
        }
    }
    return data.copy;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id command = [self objectForRow:row];
    NSView *view;
    
    if ([command isKindOfClass:ORKaleidoscopeCommand.class]) {
        ORCommandView *commandView = [tableView makeViewWithIdentifier:@"command" owner:self];
        [commandView prepareWithCommand:command];
        view = commandView;
    }
    
    if ([command isKindOfClass:ORSnapshotCreationReference.class]) {
        ORNewSnapshotView *snapshotView = [tableView makeViewWithIdentifier:@"new_snapshot" owner:self];
        [snapshotView prepareWithCommand:command];
        view = snapshotView;
    }

    if ([command isKindOfClass:NSString.class]) {
        ORTestCaseTitleView *titleFieldView = [tableView makeViewWithIdentifier:@"title" owner:self];
        [titleFieldView.titleButton setTitle: [@" Open " stringByAppendingString:command]];
        [titleFieldView.titleButton setAction:@selector(testTitleViewClicked:)];
        titleFieldView.titleButton.tag = row;
        view = titleFieldView;
    }
    
    return view;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
    id command = [self objectForRow:row];
    return [command isKindOfClass:NSString.class];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.flattenedData.count;
}

- (id)objectForRow:(NSInteger)row
{
    return [self.flattenedData objectAtIndex:row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    id command = [self objectForRow:row];
    return [command isKindOfClass:NSString.class] ? 24 : 180;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;
{
    id command = [self objectForRow:row];
    return ![command isKindOfClass:NSString.class];
}

@end
