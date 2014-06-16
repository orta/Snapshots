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

@interface ORPopoverController ()

@property (strong) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSView *detailView;

@property (weak) IBOutlet NSTableView *testTableView;
@property (weak) IBOutlet ORSlidingImageView *detailSlidingView;

@property (weak) IBOutlet NSTextField *failingTestsTitle;

@property (weak) IBOutlet NSButton *openAllButton;
@property (weak) IBOutlet NSButton *openCurrentButton;

@property (nonatomic, strong) ORLogReader *reader;
@property (nonatomic, strong) CATransition *masterDetailTransition;

@property (nonatomic, weak) ORKaleidoscopeCommand *currentCommand;

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
    self.failingTestsTitle.stringValue = [NSString stringWithFormat:@"%@ Failing snapshots", @(self.reader.uniqueDiffCommands.count)];
    
    [[self.openAllButton cell] setHighlightsBy:NSContentsCellMask];
    [[self.openCurrentButton cell] setHighlightsBy:NSContentsCellMask];

    [self.testTableView becomeFirstResponder];
    [self tableViewSelectionDidChange:nil];
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
    [commandView prepareWithCommand:command];
    
    return commandView;
}

- (void)tableViewSelectionDidChange: (NSNotification *) notification
{
    NSInteger row = [self.testTableView selectedRow];
    ORKaleidoscopeCommand *command = [self commandForRow:row];

    self.detailSlidingView.frontImage = [[NSImage alloc] initWithContentsOfFile:command.beforePath];
    self.detailSlidingView.backImage = [[NSImage alloc] initWithContentsOfFile:command.afterPath];

    self.currentCommand = command;
}

- (IBAction)tappedCurrentDiff:(id)sender
{
    [self.currentCommand launch];
}


// Other wise mainView goes out of scope on transitions

- (void)dealloc
{
    self.mainView = nil;
    self.detailView = nil;
}

@end
