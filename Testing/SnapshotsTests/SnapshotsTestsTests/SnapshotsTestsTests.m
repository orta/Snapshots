#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ORLogReader.h"

@interface ORFakeLog : NSObject
@property (nonatomic, copy) NSString *content;
@end

@implementation ORFakeLog @end

@interface SnapshotsTestsTests : XCTestCase

@end

@implementation SnapshotsTestsTests

- (void)testExample {
    ORLogReader *reader = [[ORLogReader alloc] init];

    NSString *logPath = [[NSBundle mainBundle] pathForResource:@"MultiSnapshotsPerTest" ofType:@".log"];
    NSString *log = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    for (NSString *line in [log componentsSeparatedByString:@"\n"]) {
        ORFakeLog *log = [[ORFakeLog alloc] init];
        log.content = line;
        NSNotification *notification = [NSNotification notificationWithName:@"There is standard output for the console notification" object:nil userInfo:@{ @"item": log }];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }

    XCTAssert(reader.ksdiffCommands.count == 8, @"Expected 8 diff commands");
    XCTAssert(reader.uniqueDiffCommands.count == 8, @"Expected 8 unique diff commands");
}


@end
