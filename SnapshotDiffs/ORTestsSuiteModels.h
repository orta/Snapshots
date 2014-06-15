//
//  ORTestsSuiteModels.h
//  SnapshotDiffs
//
//  Created by Orta on 6/15/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORTestCase, ORKaleidoscopeCommand;

@interface ORTestSuite : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *testCases;
@property (nonatomic, assign) BOOL hasFailingTests;

+ (ORTestSuite *)suiteFromString:(NSString *)line;
- (ORTestCase *)latestTestCase;
@end

@interface ORTestCase : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *commands;
@property (nonatomic, assign) BOOL hasFailingTests;

+ (ORTestCase *)caseFromString:(NSString *)line;
- (void)addCommand:(ORKaleidoscopeCommand *)command;
@end


@interface ORKaleidoscopeCommand : NSObject
- (void)launch;

@property (nonatomic, strong) NSString *beforePath;
@property (nonatomic, strong) NSString *afterPath;
@property (nonatomic, strong) NSString *fullCommand;
@property (nonatomic, weak) ORTestCase *testCase;

+ (instancetype)commandFromString:(NSString *)command;
@end
