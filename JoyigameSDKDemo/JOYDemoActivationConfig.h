#import <Foundation/Foundation.h>

// 公共 Demo 仅从 Info.plist 读取接入参数，仓库中保持空值。
static inline NSString *JOYDemoActivationGameId(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JOYGameId"] ?: @"";
}
static inline NSString *JOYDemoActivationAppKey(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JOYAppKey"] ?: @"";
}
static inline BOOL JOYDemoActivationConfigurationIsReady(void) {
    return JOYDemoActivationGameId().length > 0 && JOYDemoActivationAppKey().length > 0;
}
static NSNotificationName const JOYDemoActivationDidFinishNotification = @"JOYDemoActivationDidFinishNotification";
