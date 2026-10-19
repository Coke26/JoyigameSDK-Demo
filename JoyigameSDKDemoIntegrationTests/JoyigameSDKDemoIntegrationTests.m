#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "JOYDemoTestViewController.h"
#import "AppDelegate.h"
#import <JoyigameSDK/JoyigameSDK.h>

@interface AppDelegate (StartupTests)
- (UITabBarController *)buildRootTabBarController;
@end

@interface JOYDemoTestViewController (SwitchTests)
- (void)handleSDKLoginButtonTapped:(UIButton *)sender;
@end

@interface JoyigameSDKDemoIntegrationTests : XCTestCase
@property (nonatomic, assign) IMP originalSharedCenterIMP;
@property (nonatomic, assign) IMP replacementSharedCenterIMP;
@property (nonatomic, strong) JOYSDKCenter *sdkCenter;
@property (nonatomic, assign) IMP originalLoginIMP;
@property (nonatomic, assign) IMP replacementLoginIMP;
@property (nonatomic, assign) NSUInteger loginRequests;
@property (nonatomic, strong) JOYSDKLoginResult *loginResult;
@end

@implementation JoyigameSDKDemoIntegrationTests

- (void)setUp {
    [super setUp];
    // 每项测试使用独立通知来源，隔离宿主 App 长期持有的监听对象。
    self.sdkCenter = [JOYSDKCenter new];
    Method sharedMethod = class_getClassMethod(JOYSDKCenter.class, @selector(sharedCenter));
    self.originalSharedCenterIMP = method_getImplementation(sharedMethod);
    self.replacementSharedCenterIMP = imp_implementationWithBlock(^id(id object) { return self.sdkCenter; });
    method_setImplementation(sharedMethod, self.replacementSharedCenterIMP);
    self.loginResult = [JOYSDKLoginResult new];
    [self.loginResult setValue:@"new-uid" forKey:@"uid"];
    [self.loginResult setValue:@"new-player" forKey:@"username"];
    [self.loginResult setValue:@"private-token-must-not-be-shown" forKey:@"token"];
    Method method = class_getInstanceMethod(JOYSDKCenter.class, @selector(startLoginWithCompletion:));
    self.originalLoginIMP = method_getImplementation(method);
    self.replacementLoginIMP = imp_implementationWithBlock(^(JOYSDKCenter *center, JOYSDKCenterLoginCompletion completion) {
        self.loginRequests++;
        if (completion) completion(self.loginResult, nil);
    });
    method_setImplementation(method, self.replacementLoginIMP);
}

- (void)tearDown {
    method_setImplementation(class_getInstanceMethod(JOYSDKCenter.class, @selector(startLoginWithCompletion:)), self.originalLoginIMP);
    imp_removeBlock(self.replacementLoginIMP);
    method_setImplementation(class_getClassMethod(JOYSDKCenter.class, @selector(sharedCenter)), self.originalSharedCenterIMP);
    imp_removeBlock(self.replacementSharedCenterIMP);
    [super tearDown];
}

- (void)testDemoIntegrationTestTargetLoads {
    XCTAssertTrue(YES);
}

- (void)testLoginTabProvidesAccountCenterAPITestButtons {
    JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
    [controller loadViewIfNeeded];
    XCTAssertNotNil([controller.view viewWithTag:1001]);
    XCTAssertNotNil([controller.view viewWithTag:1002]);
    XCTAssertNotNil([controller.view viewWithTag:1003]);
}

- (void)testStartupSwitchIsHandledBeforeLoginTabHasLoaded {
    AppDelegate *appDelegate = [AppDelegate new];
    UITabBarController *root = [appDelegate buildRootTabBarController];
    [root loadViewIfNeeded];
    JOYDemoTestViewController *controller = (id)root.viewControllers[1];
    XCTAssertEqual(root.selectedIndex, 0U);
    XCTAssertFalse(controller.isViewLoaded);

    // 模拟启动自动登录后直接从 SDK 内部切换，玩家没有先打开登录 Tab。
    [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:JOYSDKCenter.sharedCenter];

    XCTAssertEqual(self.loginRequests, 1U);
    XCTAssertTrue(controller.isViewLoaded);
    XCTAssertEqual(root.selectedIndex, 0U);
    UILabel *status = [controller valueForKey:@"statusLabel"];
    XCTAssertTrue([status.text containsString:@"new-uid"]);
}

- (void)testObserverIsRemovedIfControllerIsReleasedBeforeViewLoads {
    __weak JOYDemoTestViewController *weakController;
    @autoreleasepool {
        JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
        weakController = controller;
        XCTAssertFalse(controller.isViewLoaded);
    }
    XCTAssertNil(weakController);
    [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:JOYSDKCenter.sharedCenter];
    XCTAssertEqual(self.loginRequests, 0U);
}

- (void)testInternalSwitchNotificationStartsHostLoginAndDisplaysCompletionResult {
    JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
    [controller loadViewIfNeeded];
    [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:JOYSDKCenter.sharedCenter];
    UILabel *status = [controller valueForKey:@"statusLabel"];
    XCTAssertEqual(self.loginRequests, 1U);
    XCTAssertTrue([status.text containsString:@"new-uid"]);
    XCTAssertTrue([status.text containsString:@"new-player"]);
    XCTAssertTrue([status.text containsString:@"token: 已返回"]);
    XCTAssertFalse([status.text containsString:@"private-token-must-not-be-shown"]);
}

- (void)testPublicLoginUsesCompletion {
    JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
    [controller loadViewIfNeeded];
    [controller handleSDKLoginButtonTapped:[controller valueForKey:@"sdkLoginButton"]];
    UILabel *status = [controller valueForKey:@"statusLabel"];
    XCTAssertEqual(self.loginRequests, 1U);
    XCTAssertTrue([status.text containsString:@"new-uid"]);
}

- (void)testDemoRegistersOnceAndFiltersOtherSenders {
    JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
    [controller loadViewIfNeeded]; [controller loadViewIfNeeded];
    [controller beginAppearanceTransition:YES animated:NO]; [controller endAppearanceTransition];
    [controller beginAppearanceTransition:NO animated:NO]; [controller endAppearanceTransition];
    [controller beginAppearanceTransition:YES animated:NO]; [controller endAppearanceTransition];
    [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:[NSObject new]];
    XCTAssertEqual(self.loginRequests, 0U);
    [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:JOYSDKCenter.sharedCenter];
    XCTAssertEqual(self.loginRequests, 1U);
}

- (void)testDemoRemovesObserverOnReleaseAndDoesNotReplayEvents {
    __weak JOYDemoTestViewController *weakController;
    @autoreleasepool {
        JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
        [controller loadViewIfNeeded]; weakController = controller;
        [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:JOYSDKCenter.sharedCenter];
    }
    XCTAssertNil(weakController);
    [NSNotificationCenter.defaultCenter postNotificationName:JOYSDKSwitchAccountDidSucceedNotification object:JOYSDKCenter.sharedCenter];
    XCTAssertEqual(self.loginRequests, 1U);
    JOYDemoTestViewController *controller = [JOYDemoTestViewController new];
    [controller loadViewIfNeeded];
    XCTAssertEqual(self.loginRequests, 1U);
}

@end
