# SafeRadius

[![Build iOS App](https://github.com/lhry716/saferadius/actions/workflows/ios.yml/badge.svg)](https://github.com/lhry716/saferadius/actions/workflows/ios.yml)

以 SwiftUI 製作的 iOS 安全互助 App 原型。

GitHub Actions：<https://github.com/lhry716/saferadius/actions>

## 開啟 iOS App

1. 用 Xcode 開啟 `SafeRadius.xcodeproj`。
2. 選擇 iPhone Simulator，按 Run。最低支援 iOS 17。要安裝到真實 iPhone，請在 Xcode 專案的 **Signing & Capabilities** 選擇自己的 Apple 開發團隊與已登入 Apple ID。
3. 若要快速展示，點畫面左下角 `DEMO` 控制列，可模擬來電、接聽、切換雙方視角、對方傳訊和協助狀態。

本機建置指令：

```sh
xcodebuild -project SafeRadius.xcodeproj -scheme SafeRadius \
  -sdk iphonesimulator -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## 核心操作

- 首頁 SOS 長按 2 秒。
- 求助等待、模擬協助者來電、接聽後進入共享語音事件。
- 通話中可聊天、切換雙方展示視角、分享示意位置、展開地圖。
- 協助者可依序標記願意前往、開始前往、已抵達。
- 掛斷語音後，求助者仍可繼續尋找協助或標記安全結束事件。

通知、通話、距離、定位、導航與聊天目前皆為本機展示模擬，不會連接真實服務或撥打緊急電話。
