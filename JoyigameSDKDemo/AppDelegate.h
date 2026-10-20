#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

/// 为单个游戏场景创建窗口，窗口就绪后仅初始化一次 SDK。
- (UIWindow *)connectWindowScene:(UIWindowScene *)windowScene;

@end
