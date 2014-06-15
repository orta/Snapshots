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
            
        
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                Class class = NSClassFromString(@"IDEToolbarDelegate");
                
                // This is nice but really we need to try and move away from using a 3rd party dep
                
                [class swizzleInstanceMethod:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) withReplacement:JGMethodReplacementProviderBlock {
                    return JGMethodReplacement(NSToolbarItem *, id, NSToolbar *toolbar, NSString *identifier, BOOL inserted) {

                        NSToolbarItem *orig = JGOriginalImplementation(NSToolbarItem *, toolbar, identifier, inserted);
                        NSString *editorID = @"Xcode.IDEKit.CustomToolbarItem.EditorMode";
                        if ([identifier isEqualToString:editorID]) {
                            
                            // Get the original switch view
                            NSView *switchView = orig.view;
                            CGSize viewSize = (CGSize){ 120, 25 };

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

                            // Make the damn button
                            NSButton *snapshotButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 1, 20, 25)];
                            snapshotButton.image = image;
                            [snapshotButton setButtonType:NSMomentaryLightButton];
                            [snapshotButton setBezelStyle:NSShadowlessSquareBezelStyle];
                            [snapshotButton setImagePosition:NSImageOnly];
                            [snapshotButton setBordered:NO];

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
    if (self.reader.hasSnapshotTestErrors) {
        NSPopover *popover = [[NSPopover alloc] init];

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
    NSBundle *bundle = [NSBundle bundleForClass:ORSnapshotDiffs.class];
    NSString *imagePath = self.reader.hasSnapshotTestErrors ? @"SnapshotToolbarIconActive" : @"SnapshotToolbarIcon";
    NSImage *image = [bundle imageForResource:imagePath];
    
    for (NSButton *button in self.buttons) {
        [button setImage:image];
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
