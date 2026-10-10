#import "AppDelegate.h"
#import "ViewController.h"
#import "JOYDemoTestViewController.h"
#import "JOYDemoPaymentViewController.h"
#import "JOYDemoActivationConfig.h"
#import <JoyigameSDK/JoyigameSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [self buildRootTabBarController];
    [self.window makeKeyAndVisible];
    [self startJoyigameSDKActivation];
    return YES;
}

- (UITabBarController *)buildRootTabBarController {
    ViewController *activationViewController = [[ViewController alloc] init];
    activationViewController.title = @"激活";
    activationViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"激活"
                                                                        image:nil
                                                                selectedImage:nil];

    JOYDemoPaymentViewController *paymentViewController = [[JOYDemoPaymentViewController alloc] init];
    paymentViewController.title = @"支付";
    paymentViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"支付"
                                                                     image:nil
                                                             selectedImage:nil];

    JOYDemoTestViewController *testViewController = [[JOYDemoTestViewController alloc] init];
    testViewController.title = @"登录";
    testViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"登录"
                                                                  image:nil
                                                          selectedImage:nil];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[activationViewController, testViewController , paymentViewController ];
    return tabBarController;
}

- (void)startJoyigameSDKActivation {
    if (!JOYDemoActivationConfigurationIsReady()) {
        NSLog(@"[JoyigameSDKDemo] 请在 Info.plist 填写 JOYGameId 和 JOYAppKey");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要配置 SDK 参数"
                message:@"请在 Info.plist 填写 JOYGameId 和 JOYAppKey 后重新运行。"
                preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        });
        return;
    }

    [JOYSDKCenter sharedCenter].debugEnabled = YES;
    [[JOYSDKCenter sharedCenter] startWithGameId:JOYDemoActivationGameId()
                                         appKey:JOYDemoActivationAppKey()
                                     completion:^(JOYActivationConfig * _Nullable config, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[JoyigameSDKDemo] 激活失败: %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:JOYDemoActivationDidFinishNotification
                                                                object:nil
                                                              userInfo:@{@"error": error}];
            return;
        }

        NSLog(@"[JoyigameSDKDemo] 激活成功: debug=%ld review=%@ floatBall=%ld autoLogin=%ld",
              (long)config.isDebugEnabled,
              config.review,
              (long)config.isFloatBallEnabled,
              (long)config.isAutoLoginEnabled);
        [[NSNotificationCenter defaultCenter] postNotificationName:JOYDemoActivationDidFinishNotification
                                                            object:nil
                                                          userInfo:@{@"config": config}];
        [self startJoyigameSDKLoginAfterActivation];
    }];
}

- (void)startJoyigameSDKLoginAfterActivation {
    // Demo 启动链路模拟游戏工程：激活成功后立即交给 SDK 决定自动登录或展示登录页。
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JOYSDKCenter sharedCenter] startLoginWithCompletion:^(JOYSDKLoginResult * _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"[JoyigameSDKDemo] 启动登录未完成: %@", error.localizedDescription ?: error);
                return;
            }
            NSLog(@"[JoyigameSDKDemo] 启动登录成功: uid=%@ username=%@", result.uid ?: @"", result.username ?: @"");
        }];
    });
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[JOYSDKCenter sharedCenter] application:application openURL:url options:options];
}

@end
