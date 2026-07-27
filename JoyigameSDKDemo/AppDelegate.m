#import "AppDelegate.h"
#import "ViewController.h"
#import "JOYDemoLoginViewController.h"
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

    JOYDemoLoginViewController *loginViewController = [[JOYDemoLoginViewController alloc] init];
    loginViewController.title = @"登录";
    loginViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"登录"
                                                                  image:nil
                                                          selectedImage:nil];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[activationViewController, loginViewController, paymentViewController];
    return tabBarController;
}

- (void)startJoyigameSDKActivation {
    if (!JOYDemoActivationConfigurationIsReady()) {
        NSError *error = [NSError errorWithDomain:@"com.joyigame.sdk.demo"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"请先在 JoyigameSDKDemo/Info.plist 填写 JOYGameId 和 JOYAppKey"}];
        NSLog(@"[JoyigameSDKDemo] %@", error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:JOYDemoActivationDidFinishNotification
                                                            object:nil
                                                          userInfo:@{ @"error": error }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentConfigurationRequiredAlert];
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
    }];
}

- (void)presentConfigurationRequiredAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"需要配置 SDK 参数"
                                                                             message:@"请在 JoyigameSDKDemo/Info.plist 填写 JOYGameId 和 JOYAppKey，然后重新运行 Demo。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[JOYSDKCenter sharedCenter] application:application openURL:url options:options];
}

@end
