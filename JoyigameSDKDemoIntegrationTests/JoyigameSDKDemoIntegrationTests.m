#import <XCTest/XCTest.h>
#import "JOYDemoTestViewController.h"

@interface JoyigameSDKDemoIntegrationTests : XCTestCase
@end

@implementation JoyigameSDKDemoIntegrationTests

- (void)testDemoIntegrationTestTargetLoads {
    XCTAssertTrue(YES);
}

- (void)testLoginTabProvidesAccountCenterAPITestButtons {
    JOYDemoTestViewController *viewController = [[JOYDemoTestViewController alloc] init];
    [viewController loadViewIfNeeded];

    XCTAssertNotNil([viewController.view viewWithTag:1001]);
    XCTAssertNotNil([viewController.view viewWithTag:1002]);
    XCTAssertNotNil([viewController.view viewWithTag:1003]);
}

@end
