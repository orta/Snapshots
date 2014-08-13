//
//  ORPopoverController.m
//  SnapshotDiffs
//
//  Created by Orta on 6/13/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORPopoverController.h"
#import "ORLogReader.h"
#import "ORCommandView.h"
#import "ORSlidingImageView.h"
#import "ORPopoverTableDataSource.h"
#import "ORTableViewRowView.h"

@import Quartz;

@interface ORPopoverController ()

@property (strong) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSView *detailView;

@property (weak) IBOutlet NSTableView *testTableView;
@property (weak) IBOutlet ORSlidingImageView *detailSlidingView;
@property (weak) IBOutlet NSImageView *plainImagePreviewView;

@property (weak) IBOutlet NSTextField *failingTestsTitle;

@property (weak) IBOutlet NSButton *openAllButton;
@property (weak) IBOutlet NSButton *openCurrentButton;
@property (weak) IBOutlet NSTextField *detailTestDescription;

@property (weak) ORTableViewRowView *currentTableViewSelection;

@property (nonatomic, strong) ORLogReader *reader;
@property (nonatomic, strong) CATransition *masterDetailTransition;

@property (nonatomic, strong) ORPopoverTableDataSource *tableDataSource;

@property (nonatomic, weak) ORKaleidoscopeCommand *currentCommand;

@end

@implementation ORPopoverController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil reader:(ORLogReader *)reader
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
    
    _reader = reader;
    _tableDataSource = [[ORPopoverTableDataSource alloc] initWithReader:reader];
    
    return self;
}

- (void)awakeFromNib
{
    self.failingTestsTitle.stringValue = [NSString stringWithFormat:@"%@ Failing snapshots", @(self.reader.uniqueDiffCommands.count)];
    
    [[self.openAllButton cell] setHighlightsBy:NSContentsCellMask];
    [[self.openCurrentButton cell] setHighlightsBy:NSContentsCellMask];

    self.testTableView.dataSource = self.tableDataSource;
    [self.testTableView reloadData];
    [self.testTableView becomeFirstResponder];
    
    [self tableViewSelectionDidChange:nil];

    NSInteger selectedRow = [self.testTableView selectedRow];
    ORTableViewRowView *view = [self.testTableView viewAtColumn:0 row:selectedRow makeIfNecessary:YES];
    self.currentTableViewSelection = view;
    [view setSelected:YES];
}

- (IBAction)openAll:(id)sender
{
    for (ORKaleidoscopeCommand *command in self.reader.uniqueDiffCommands) {
        [command launch];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [self.testTableView selectedRow];
    id command = [self.tableDataSource objectForRow:row];

    if ([command isKindOfClass:ORKaleidoscopeCommand.class]) {
        self.detailSlidingView.hidden = NO;
        self.plainImagePreviewView.hidden = YES;
        
        self.detailSlidingView.frontImage = [[NSImage alloc] initWithContentsOfFile:[command beforePath]];
        self.detailSlidingView.backImage = [[NSImage alloc] initWithContentsOfFile:[command afterPath]];
        
        self.detailSlidingView.frontMessage = @"Reference";
        self.detailSlidingView.backMessage = @"Recorded";
        
        self.detailTestDescription.stringValue = [command testCase].name;
        self.currentCommand = command;
    }
    
    if ([command isKindOfClass:ORSnapshotCreationReference.class]) {
        self.detailSlidingView.hidden = YES;
        self.plainImagePreviewView.hidden = NO;
        
        self.plainImagePreviewView.image = [[NSImage alloc] initWithContentsOfFile:[command path]];
        self.detailTestDescription.stringValue = [command testCase].name;
    }
    
}

- (IBAction)tappedCurrentDiff:(id)sender
{
    [self.currentCommand launch];
}

- (void)testTitleViewClicked:(NSButton *)sender
{
    ORKaleidoscopeCommand *firstCommandInTestCase = [self.tableDataSource objectForRow:sender.tag + 1];
    NSString *filePath = [firstCommandInTestCase.projectLocation componentsSeparatedByString:@":"].firstObject;
    [[NSApplication sharedApplication].delegate application:NSApp openFile:filePath];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.tableDataSource objectForRow:row];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.tableDataSource numberOfRowsInTableView:tableView];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.tableDataSource tableView:tableView viewForTableColumn:tableColumn row:row];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
    return [self.tableDataSource tableView:tableView isGroupRow:row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return [self.tableDataSource tableView:tableView heightOfRow:row];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;
{
    BOOL should = [self.tableDataSource tableView:tableView shouldSelectRow:row];
    if (should) {
        [self.currentTableViewSelection setSelected:NO];
        ORTableViewRowView *view = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
        self.currentTableViewSelection = view;
        [view setSelected:YES];
    }
    return should;
}

// Other wise mainView goes out of scope on transitions

- (void)dealloc
{
    self.mainView = nil;
    self.detailView = nil;
}

@end
