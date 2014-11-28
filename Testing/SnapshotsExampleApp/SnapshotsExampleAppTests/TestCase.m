#define EXP_SHORTHAND

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta/Expecta.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

@interface TestCase : FBSnapshotTestCase
@end

@implementation TestCase

- (void)testFails
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    view.backgroundColor = [UIColor redColor];
    expect(view).to.recordSnapshotNamed(@"fail");
}

- (void)testChangedImage
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 560)];
    view.backgroundColor = [UIColor redColor];
    expect(view).to.haveValidSnapshotNamed(@"changed");
}


- (void)testSuccess
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    view.backgroundColor = [UIColor blueColor];
    expect(view).to.haveValidSnapshotNamed(@"success");
}

- (void)testMutlipleFails
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    view.backgroundColor = [UIColor darkGrayColor];
    expect(view).will.haveValidSnapshotNamed(@"success3");
}


@end