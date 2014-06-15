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

@interface ORPopoverController ()
@property (weak) IBOutlet NSTextField *failingTestsTitle;
@property (weak) IBOutlet NSButton *openAllButton;
@property (nonatomic, strong) ORLogReader *reader;
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

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ORKaleidoscopeCommand *command = [self commandForRow:row];
    
    ORCommandView *commandView = [tableView makeViewWithIdentifier:@"command" owner:self];
    commandView.fromImageView.image = [[NSImage alloc] initWithContentsOfFile:command.beforePath];
    commandView.toImageView.image = [[NSImage alloc] initWithContentsOfFile:command.afterPath];
    commandView.testCaseTitle.stringValue = command.testCase.name;
    commandView.command = command;
    
    return commandView;

}

@end
