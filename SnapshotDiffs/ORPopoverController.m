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
@import Quartz;

@interface ORPopoverController () <ORSlidingImageViewClickDelegate>

@property (strong) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSView *detailView;

@property (weak) IBOutlet NSTableView *testTableView;
@property (weak) IBOutlet ORSlidingImageView *detailSlidingView;

@property (weak) IBOutlet NSTextField *failingTestsTitle;
@property (weak) IBOutlet NSButton *openAllButton;

@property (nonatomic, strong) ORLogReader *reader;
@property (nonatomic, strong) CATransition *masterDetailTransition;

@end

@implementation ORPopoverController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil reader:(ORLogReader *)reader
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
    
    _reader = reader;
    
    return self;
}

- (void)awakeFromNib
{
    self.failingTestsTitle.stringValue = [NSString stringWithFormat:@"%@ Failing snapshot tests", @(self.reader.uniqueDiffCommands.count)];
    
    [[self.openAllButton cell] setHighlightsBy:NSContentsCellMask];
    
    [self.testTableView setTarget:self];
    [self.testTableView setDoubleAction:@selector(doubleClickCell:)];
    
    _masterDetailTransition = [CATransition animation];
    [self.masterDetailTransition setType:kCATransitionPush];
    [self.masterDetailTransition setSubtype:kCATransitionFromLeft];
    [self.view setAnimations:@{ @"subviews" : self.masterDetailTransition}];
}

- (IBAction)openAll:(id)sender
{
    for (ORKaleidoscopeCommand *command in self.reader.uniqueDiffCommands) {
        [command launch];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.reader.uniqueDiffCommands.count;
}

- (ORKaleidoscopeCommand *)commandForRow:(NSInteger)row
{
    return self.reader.uniqueDiffCommands[row];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ORKaleidoscopeCommand *command = [self commandForRow:row];
    
    ORCommandView *commandView = [tableView makeViewWithIdentifier:@"command" owner:self];
    NSImage *before = [[NSImage alloc] initWithContentsOfFile:command.beforePath];
    NSImage *to = [[NSImage alloc] initWithContentsOfFile:command.afterPath];
    commandView.fromImageView.image = before;
    commandView.toImageView.image = to;
    
    commandView.testCaseTitle.stringValue = command.testCase.name;
    
    commandView.command = command;
    
    return commandView;
}

- (void)doubleClickCell:(NSTableView *)tableView
{
    NSInteger row = [tableView clickedRow];
    ORKaleidoscopeCommand *command = [self commandForRow:row];
    
    self.detailSlidingView.frontImage = [[NSImage alloc] initWithContentsOfFile:command.beforePath];
    self.detailSlidingView.backImage = [[NSImage alloc] initWithContentsOfFile:command.afterPath];
    self.detailSlidingView.clickDelegate = self;
    
    [self.masterDetailTransition setSubtype:kCATransitionFromRight];
    [self.view.animator replaceSubview:self.mainView with:self.detailView];
}

- (void)doubleClickedOnSlidingView:(ORSlidingImageView *)imageView
{
    [self backButtonTapped:self];
}

- (IBAction)backButtonTapped:(id)sender
{
    [self.masterDetailTransition setSubtype:kCATransitionFromLeft];
    [self.view.animator replaceSubview:self.detailView with:self.mainView];
}

// Other wise mainView goes out of scope on transitions

- (void)dealloc
{
    self.mainView = nil;
    self.detailView = nil;
}

@end
