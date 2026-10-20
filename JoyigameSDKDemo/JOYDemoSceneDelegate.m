#import "JOYDemoSceneDelegate.h"
#import "AppDelegate.h"
#import <JoyigameSDK/JoyigameSDK.h>

@implementation JOYDemoSceneDelegate

- (void)scene:(UIScene *)scene
        willConnectToSession:(UISceneSession *)session
        options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class]) return;
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    self.window = [appDelegate connectWindowScene:(UIWindowScene *)scene];
    // App 未运行时通过登录回跳启动，URL 由连接参数传入。
    [self scene:scene openURLContexts:connectionOptions.URLContexts];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    for (UIOpenURLContext *context in URLContexts) {
        NSMutableDictionary<UIApplicationOpenURLOptionsKey, id> *options = [NSMutableDictionary dictionary];
        if (context.options.sourceApplication) {
            options[UIApplicationOpenURLOptionsSourceApplicationKey] = context.options.sourceApplication;
        }
        if (context.options.annotation) {
            options[UIApplicationOpenURLOptionsAnnotationKey] = context.options.annotation;
        }
        options[UIApplicationOpenURLOptionsOpenInPlaceKey] = @(context.options.openInPlace);
        [[JOYSDKCenter sharedCenter] application:UIApplication.sharedApplication
                                        openURL:context.URL options:options];
    }
}

@end
