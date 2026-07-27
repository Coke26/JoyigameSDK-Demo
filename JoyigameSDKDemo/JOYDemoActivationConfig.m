#import "JOYDemoActivationConfig.h"

NSNotificationName const JOYDemoActivationDidFinishNotification = @"JOYDemoActivationDidFinishNotification";

// 公开 Demo 不依赖本地 xcconfig，直接读取 Info.plist 中由接入方填写的激活参数。
static NSString *JOYDemoConfigurationValue(NSString *key) {
    id value = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
    return [value isKindOfClass:NSString.class] ? value : @"";
}

static BOOL JOYDemoConfigurationValueIsPlaceholder(NSString *value) {
    return value.length == 0 || [value hasPrefix:@"$("] || [value hasPrefix:@"<"];
}

NSString *JOYDemoActivationGameId(void) {
    return JOYDemoConfigurationValue(@"JOYGameId");
}

NSString *JOYDemoActivationAppKey(void) {
    return JOYDemoConfigurationValue(@"JOYAppKey");
}

BOOL JOYDemoActivationConfigurationIsReady(void) {
    return !JOYDemoConfigurationValueIsPlaceholder(JOYDemoActivationGameId()) &&
           !JOYDemoConfigurationValueIsPlaceholder(JOYDemoActivationAppKey());
}
