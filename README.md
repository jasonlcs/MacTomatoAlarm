# MacTomatoAlarm 🍅

macOS 選單列番茄鐘 — 輕量、專注、可自訂。

![macOS 14+](https://img.shields.io/badge/macOS-14+-brightgreen)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## 功能

- **選單列操作** — 從選單列直接控制計時器，不干擾工作
- **三種階段** — 專注 / 短休息 / 長休息，自動循環
- **預設模式** — 經典 (25/5/15)、長專注 (50/10/20)、衝刺 (15/5/15)
- **自訂計時** — 自由調整專注與休息時間
- **螢幕頂端疊層** — 倒數最後 3 秒在螢幕頂端顯示大字提示
- **音效提醒** — 階段完成時播放提示音
- **通知** — 階段完成時發送系統通知
- **自動下一階段** — 可開啟自動連續模式
- **每日統計** — 自動記錄每日完成 session 數
- **俐落 DMG** — 拖曳到 Applications 即可安裝

## 安裝

1. 從 [Releases](https://github.com/jasonlcs/MacTomatoAlarm/releases) 下載最新 `MacTomatoAlarm.dmg`
2. 打開 DMG，將 `MacTomatoAlarm.app` 拖曳到 `Applications` 資料夾
3. 從 Launchpad 或 `Applications` 開啟

## 從原始碼建置

```bash
git clone https://github.com/jasonlcs/MacTomatoAlarm.git
cd MacTomatoAlarm
./build-app.sh
```

產出位於 `.build/app/`：
- `MacTomatoAlarm.app`
- `MacTomatoAlarm.dmg`

### 需求

- macOS 14 (Sonoma) 以上
- Xcode 15 或 Command Line Tools

## 技術架構

| 層 | 技術 |
|---|---|
| 語言 | Swift 5.9 |
| UI 框架 | SwiftUI + AppKit |
| 建置工具 | Swift Package Manager |
| 選單列 | `MenuBarExtra` |
| 疊層視窗 | `NSPanel` (無邊框、浮動) |
| 通知 | `UserNotifications` |
| 音效 | `NSSound` 系統音效 |
| 資料儲存 | `UserDefaults` |

## License

MIT
