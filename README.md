# JoyigameSDK-Demo

`JoyigameSDK` 的 CocoaPods 独立接入 Demo。此仓库不包含 Joyigame SDK 源码、不引用本地联合工程，也不包含 gameId、appKey 或第三方登录凭据。

## 运行步骤

1. 打开 `JoyigameSDKDemo/Info.plist`，填写由 Joyigame 提供的激活参数。仓库中的 `JOYGameId`、`JOYAppKey`、Facebook 和 Google 字段默认均为空，禁止提交真实值。
2. 安装 Pod：

   ```bash
   pod install --repo-update
   open JoyigameSDKDemo.xcworkspace
   ```

3. 必须使用 `JoyigameSDKDemo.xcworkspace`（不能使用 `.xcodeproj`）打开并运行 `JoyigameSDKDemo` scheme。未配置参数时，Demo 会在控制台和启动弹窗提示填写 `Info.plist`，且不会请求激活接口。

## SDK 接入

```ruby
source "https://github.com/Coke26/JoyigameSDK-Specs.git"
source "https://cdn.cocoapods.org/"

pod "JoyigameSDK"
```

Demo 不固定 SDK 版本，也不提交 `Podfile.lock`。新 clone 后运行 `pod install --repo-update` 会安装当前最新版本；已安装旧版本时执行：

```bash
pod update JoyigameSDK
```

Objective-C 导入路径保持正式 SDK 名称：

```objc
#import <JoyigameSDK/JoyigameSDK.h>
```

## 安全规则

- 不要提交任何 appKey、token、账号、Google 配置文件或 Facebook/Google 生产配置。
- 本仓库只用于验证 CocoaPods 二进制接入；私有 `JoyigameSDKDemo` 联合工程继续用于 SDK 开发调试。
