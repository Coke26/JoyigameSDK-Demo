#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HEADER="${ROOT_DIR}/JoyigameSDKDemo/JOYDemoActivationConfig.h"
CONFIG_SOURCE="${ROOT_DIR}/JoyigameSDKDemo/JOYDemoActivationConfig.m"
APP_DELEGATE_SOURCE="${ROOT_DIR}/JoyigameSDKDemo/AppDelegate.m"
INFO_PLIST="${ROOT_DIR}/JoyigameSDKDemo/Info.plist"
PROJECT_SPEC="${ROOT_DIR}/project.yml"
README="${ROOT_DIR}/README.md"

rg -q 'FOUNDATION_EXPORT NSString \*JOYDemoActivationGameId\(void\);' "${CONFIG_HEADER}"
rg -q 'FOUNDATION_EXPORT NSString \*JOYDemoActivationAppKey\(void\);' "${CONFIG_HEADER}"
rg -q 'objectForInfoDictionaryKey:key' "${CONFIG_SOURCE}"
rg -q 'JOYDemoConfigurationValue\(@"JOYGameId"\)' "${CONFIG_SOURCE}"
rg -q 'JOYDemoConfigurationValue\(@"JOYAppKey"\)' "${CONFIG_SOURCE}"
[[ -z "$(plutil -extract JOYGameId raw -o - "${INFO_PLIST}")" ]]
[[ -z "$(plutil -extract JOYAppKey raw -o - "${INFO_PLIST}")" ]]
! rg -q 'configFiles:|DemoConfig\.xcconfig' "${PROJECT_SPEC}"
rg -q 'Info\.plist' "${CONFIG_SOURCE}"
rg -q 'presentConfigurationRequiredAlert' "${APP_DELEGATE_SOURCE}"
rg -q 'UIAlertController' "${APP_DELEGATE_SOURCE}"
! rg -q 'DemoConfig\.xcconfig' "${README}"

printf '[DemoConfiguration] configuration contract passed\n'
