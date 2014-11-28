//
//  ORSnapshotDiffs.m
//  ORSnapshotDiffs
//
//  Created by Orta on 6/12/14.
//    Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORSnapshotDiffs.h"
#import "ORLogReader.h"
#import <objc/runtime.h>
#import "JGMethodSwizzler.h"
#import "ORPopoverController.h"

static ORSnapshotDiffs *sharedPlugin;

@interface ORSnapshotDiffs()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) ORLogReader *reader;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation ORSnapshotDiffs

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];

            static dispatch_once_t secondOnceToken;
            dispatch_once(&secondOnceToken, ^{
                Class class = NSClassFromString(@"IDEToolbarDelegate");
                
                // This is nice but really I need to try and move away from using a 3rd party dep
                
                [class swizzleInstanceMethod:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) withReplacement:JGMethodReplacementProviderBlock {
                    return JGMethodReplacement(NSToolbarItem *, id, NSToolbar *toolbar, NSString *identifier, BOOL inserted) {

                        NSToolbarItem *orig = JGOriginalImplementation(NSToolbarItem *, toolbar, identifier, inserted);
                        NSString *editorID = @"Xcode.IDEKit.CustomToolbarItem.EditorMode";
                        if ([identifier isEqualToString:editorID]) {
                            
                            // Get the original switch view
                            NSView *switchView = orig.view;
                            CGSize viewSize = (CGSize){ 160, 25 };

                            // Make a new container that's wider
                            NSView *holder = [[NSView alloc] initWithFrame:(CGRect){0, 0, viewSize}];
                            [holder addSubview:switchView];
                            orig.view = holder;
                            
                            // Offset the original switch view giving some left-hand space for the new button
                            CGRect newSwitchFrame = orig.view.frame;
                            newSwitchFrame.origin.x = viewSize.width - switchView.frame.size.width;
                            switchView.frame = newSwitchFrame;
                            
                            NSBundle *bundle = [NSBundle bundleForClass:ORSnapshotDiffs.class];
                            NSImage *image = [bundle imageForResource:@"SnapshotToolbarIcon"];
                            NSImage *separatorImage = [bundle imageForResource:@"SeparatorImage"];
                            
                            NSImageView *imageView = [[NSImageView alloc] initWithFrame:CGRectMake(newSwitchFrame.origin.x - 10, 3, 2, 18)];
                            imageView.image = separatorImage;
                            [holder addSubview:imageView];
                            
                            // Make the damn button
                            CGRect snapshotFrame = CGRectMake(imageView.frame.origin.x - 14 - 14, 0, 20, 25);
                            NSButton *snapshotButton = [[NSButton alloc] initWithFrame:snapshotFrame];
                            snapshotButton.image = image;
                            snapshotButton.alternateImage = image;
                            [snapshotButton setButtonType:NSMomentaryPushInButton];
                            [snapshotButton setBezelStyle:NSShadowlessSquareBezelStyle];
                            [snapshotButton setImagePosition:NSImageOnly];
                            [snapshotButton setBordered:NO];
                            [[snapshotButton cell] setHighlightsBy:NSContentsCellMask];

                            [snapshotButton setTarget:sharedPlugin];
                            [snapshotButton setAction:@selector(tappedButton:)];
                            [holder addSubview:snapshotButton];
                            
                            [sharedPlugin.buttons addObject:snapshotButton];
                            orig.maxSize = viewSize;
                            orig.minSize = viewSize;
                        }
                        
                        return orig;
                    };
                }];

            });
        });
    }
}

- (void)tappedButton:(NSButton *)button
{
    if (self.reader.hasSnapshotTestErrors || self.reader.hasNewSnapshots) {
        NSPopover *popover = [[NSPopover alloc] init];
        popover.contentSize = CGSizeMake(575, 480);
        NSString *class = NSStringFromClass(ORPopoverController.class);
        NSBundle *bundle = [NSBundle bundleForClass:ORSnapshotDiffs.class];

        ORPopoverController *controller = [[ORPopoverController alloc] initWithNibName:class bundle:bundle reader:self.reader];
        popover.contentViewController = controller;
        popover.behavior = NSPopoverBehaviorTransient;
        
        [popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSMaxYEdge];
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    self = [super init];
    if (!self) return nil;
    
    self.bundle = plugin;
    self.buttons = [NSMutableArray array];
    self.reader = [[ORLogReader alloc] init];

    [self registerForNotifications];
    
    return self;
}

- (void)registerForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(resetLog:) name:@"IDEBuildOperationWillStartNotification" object:nil];

    [center addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
    [center addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:nil];

    NSArray *notifications = @[
        @"IDEWorkspaceDocumentWillWriteStateDataNotification",
        @"IDEBuildOperationDidStopNotification",
        @"IDEBuildIssueProviderUpdatedIssuesNotification",
        @"CurrentExecutionTrackerCompletedNotification"
    ];
    
    for (NSString *string in notifications) {
        [center addObserver:self selector:@selector(updateToolbarIcon:) name:string object:nil];
    }
}

- (void)updateToolbarIcon:(NSNotification *)notification
{
    NSString *imagePath = self.reader.hasSnapshotTestErrors ? @"SnapshotToolbarIconActive" : @"SnapshotToolbarIcon";
    imagePath = self.reader.hasCGErrors ? @"SnapshotToolbarIconError" : imagePath;
    
    NSImage *image = [self.bundle imageForResource:imagePath];
    
    for (NSButton *button in self.buttons) {
        button.image = image;
        button.alternateImage = image;
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    for (NSButton *button in self.buttons) {
        [button setAlphaValue:1];
    }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    for (NSButton *button in self.buttons) {
        [button setAlphaValue:0.5];
    }
}

- (void)resetLog:(NSNotification *)notification
{
    [self.reader erase];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
