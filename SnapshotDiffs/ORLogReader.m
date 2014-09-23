//
//  ORLogReader.m
//  SnapshotDiffs
//
//  Created by Orta on 6/12/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORLogReader.h"
#import "NSFileManager+RecursiveFind.h"
#import "NSString+StringBetweenStrings.h"

// This is to allow using id with
// https://github.com/luisobo/Xcode-RuntimeHeaders/blob/master/IDEFoundation/IDEConsoleItem.h

@interface ORIDEThing : NSObject
- (NSString *)content;
@end


@interface ORLogReader()
@property (nonatomic, readonly, strong) NSMutableString *mutableLog;

@property (nonatomic, readonly, strong) NSMutableOrderedSet *mutableTestSuites;
@property (nonatomic, readonly, strong) NSMutableOrderedSet *mutableDiffCommands;
@property (nonatomic, readonly, strong) NSMutableOrderedSet *mutableSnapshotCreations;
@end

@implementation ORLogReader

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLogNotification:) name:@"There is standard output for the console notification" object:nil];

    [self erase];

    return self;
}

- (NSArray *)testSuites
{
    return self.mutableTestSuites.array;
}


- (ORTestSuite *)latestTestSuite
{
    return self.mutableTestSuites.lastObject;
}

- (void)gotLogNotification:(NSNotification *)notification
{
    id fullLog = notification.userInfo[@"item"];

    NSString *log = [fullLog content];

    [self.mutableLog appendString:log];
 
    for (NSString *line in [log componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet]) {
        if ([line rangeOfString:@"Test Suite"].location != NSNotFound) {
            ORTestSuite *suite = [ORTestSuite suiteFromString:line];
            if (suite) [self.mutableTestSuites addObject:suite];
        }
        
        if ([line rangeOfString:@"Test Case"].location != NSNotFound) {
            if ([line rangeOfString:@"started."].location != NSNotFound) {
                ORTestCase *testCase = [ORTestCase caseFromString:line];
                if (testCase) [self.latestTestSuite.testCases addObject:testCase];
                
            } else if ([line rangeOfString:@"' failed ("].location != NSNotFound) {
                [self.mutableDiffCommands.lastObject setFails:YES];
            }
        }
        
        if ([line rangeOfString:@"ksdiff"].location != NSNotFound) {
            NSString *commandString = [self extractCommandFromLine:line];
            ORKaleidoscopeCommand *command = [ORKaleidoscopeCommand commandFromString:commandString];
            if (command) {
                [self.mutableDiffCommands addObject:command];
                [self.latestTestSuite.latestTestCase addCommand:command];
            }
        }
        
        if ([line rangeOfString:@"This application, or a library it uses, is using an invalid context"].location != NSNotFound) {
            _hasCGErrors = YES;
        }
        
        if ([line rangeOfString:@"]"].location != NSNotFound && [line rangeOfString:@"expected a matching snapshot"].location != NSNotFound) {
            NSString *filepathAndLine = [line or_substringBetween:@"] " and:@" expected a matching snapshot"];
            if (filepathAndLine && filepathAndLine.length > 1) {
                [self.latestTestSuite.latestTestCase.commands makeObjectsPerformSelector:@selector(setProjectLocation:) withObject:filepathAndLine];
            }
        }

        if ([line rangeOfString:@"successfully recorded"].location != NSNotFound) {
            ORSnapshotCreationReference *snapshot = [ORSnapshotCreationReference referenceFromString:line];

            if (snapshot) {
                ORTestCase *testCase = self.latestTestSuite.latestTestCase;
                NSString *path = [[NSFileManager defaultManager] or_findFileWithNamePrefix:snapshot.name inFolder:self.latestTestSuite.name];
                path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                snapshot.path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];

                if (![self.mutableSnapshotCreations containsObject:snapshot]) {
                    [self.mutableSnapshotCreations addObject:snapshot];
                    [testCase addSnapshot:snapshot];
                }
            }
        }
    }
}

- (NSString *)extractCommandFromLine:(NSString *)line
{
    return [line componentsSeparatedByString:@"diff:\n"].lastObject;
}

- (BOOL)hasNewSnapshots
{
    return (self.mutableSnapshotCreations.count > 0);

}

- (BOOL)hasSnapshotTestErrors
{
    return (self.uniqueDiffCommands.count > 0);
}

- (NSArray *)ksdiffCommands
{
    return [self.mutableDiffCommands.array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ORKaleidoscopeCommand *command, NSDictionary *bindings) {
        return command.fails;
    }]];
}

- (NSArray *)uniqueDiffCommands
{
    NSArray *commands = [self ksdiffCommands];
    if (commands.count == 1) return commands;

    return [commands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ORKaleidoscopeCommand *command, NSDictionary *bindings) {
        return [[NSFileManager defaultManager] contentsEqualAtPath:command.afterPath andPath:command.beforePath] == NO;
    }]];
}

- (NSString *)log
{
    return [NSString stringWithString:self.mutableLog];
}

- (void)erase
{
    _mutableLog = [NSMutableString string];
    _mutableDiffCommands = [NSMutableOrderedSet orderedSet];
    _mutableTestSuites = [NSMutableOrderedSet orderedSet];
    _mutableSnapshotCreations = [NSMutableOrderedSet orderedSet];
    _hasCGErrors = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
