#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 公开 Demo 从 Info.plist 读取 gameId；仓库默认值为空，接入方在本地填写。
FOUNDATION_EXPORT NSString *JOYDemoActivationGameId(void);

/// 公开 Demo 从 Info.plist 读取 appKey；仓库默认值为空，接入方在本地填写。
FOUNDATION_EXPORT NSString *JOYDemoActivationAppKey(void);

/// 判断 Info.plist 中的激活参数是否已填写，未完成配置时不得请求后端。
FOUNDATION_EXPORT BOOL JOYDemoActivationConfigurationIsReady(void);

FOUNDATION_EXPORT NSNotificationName const JOYDemoActivationDidFinishNotification;

NS_ASSUME_NONNULL_END
