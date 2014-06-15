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
@property (nonatomic, weak) IBOutlet NSScrollView *scrollView;
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
    [self addViewsFromReader:_reader];
}

- (IBAction)openAll:(id)sender
{
    for (ORKaleidoscopeCommand *command in self.reader.uniqueDiffCommands) {
        [command launch];
    }
}

- (void)addViewsFromReader:(ORLogReader *)reader
{
    NSInteger index = 0, height = 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    for (ORKaleidoscopeCommand *command in reader.uniqueDiffCommands) {
        NSBundle *bundle = [NSBundle bundleForClass:ORPopoverController.class];
        NSString *stringName = NSStringFromClass(ORPopoverController.class);
        NSArray *views;
        [bundle loadNibNamed:stringName owner:nil topLevelObjects:&views];
        
        for (NSView *view in views) {
            if ([view isKindOfClass:ORCommandView.class]) {
                
                ORCommandView *commandView = (id)view;
                
                commandView.command = command;
                commandView.fromImageView.image = [[NSImage alloc] initWithContentsOfFile:command.beforePath];
                commandView.toImageView.image = [[NSImage alloc] initWithContentsOfFile:command.afterPath];
                
                view.frame = CGRectMake(0, -index * CGRectGetHeight(view.bounds), width, view.bounds.size.height);
                [self.scrollView.documentView addSubview:view];
                height += CGRectGetHeight(view.bounds);
            }
        }
        
        index += 1;

    }
    
    [self.scrollView.documentView setFrameSize:CGSizeMake(width, height)];

}

@end
