# Adjust 包配置

按实际 Bundle ID 命名 JSON，并填写同一个 `bundleId`、当前项目 `appToken` 和按需 `eventTokens`。构建按 Bundle ID 生成 App 根目录的 `JoyiAdjustProfile.json`。事件 token 原样交给 SDK，未配置事件跳过；JSON 不支持注释。当前空配置在 Debug 停用 Adjust，Release 需填写有效 App Token。
