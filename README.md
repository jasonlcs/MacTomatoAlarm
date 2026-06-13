# MacTomatoAlarm 🍅

macOS 選單列番茄鐘 — 輕量、專注、可自訂。

![macOS 14+](https://img.shields.io/badge/macOS-14+-brightgreen)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
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
3. 首次執行時，若出現「無法驗證是否為惡意軟體」，對 App **按右鍵 → 打開** 即可（僅需一次）

> Release 版本若已設定 Developer ID 簽名（見下方），則不會出現 Gatekeeper 警告，可直接打開。

## 設定 Developer ID 簽名（CI）

若你有 Apple Developer 帳號，可在 CI 加入正式簽名，消除 Gatekeeper 警告：

### 1. 匯出憑證

```bash
# 在本機 Keychain Access 中：
#   鑰匙圈存取 → 憑證輔助程式 → 向憑證授權要求憑證
#   到 developer.apple.com → Certificates → 新增「Developer ID Application」
#   下載 .cer 後點兩下安裝，再從 Keychain Access 右鍵輸出為 .p12（設定密碼）
```

### 2. 轉成 base64 並寫入 GitHub Secrets

```bash
base64 -i /path/to/certificate.p12 | pbcopy
```

在 GitHub repo → Settings → Secrets and variables → Actions，新增兩個 secrets：

| Secret | 說明 |
|---|---|
| `DEVELOPER_CERTIFICATE_BASE64` | 上面複製的 base64 字串 |
| `CERTIFICATE_PASSWORD` | .p12 的密碼 |

設定後下一次推送 tag 觸發 CI 時，build 會自動使用 Developer ID 簽名。若未設定 secrets，則回退為 ad-hoc 簽名。

## 疑難排解

| 問題 | 解決方法 |
|---|---|
| App 打開後沒有反應 / 閃退 | 確認 macOS ≥ 14；若從 DMG 安裝，務必先複製到 Applications 再執行 |
| 「無法打開，應丟到垃圾桶」 | 右鍵點擊 App →「打開」；或在「系統設定 → 隱私權與安全性」允許 |
| 選單列沒有出現圖示 | 系統可能隱藏了選單列 icon，到「系統設定 → 控制中心」調整選單列項目 |
| 通知沒出現 | 確認「系統設定 → 通知」中 MacTomatoAlarm 的通知已開啟 |

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
- Xcode 16 以上 或 Command Line Tools for Xcode
- Swift 6（`swift --version`）

## 技術架構

| 層 | 技術 |
|---|---|
| 語言 | Swift 6 |
| UI 框架 | SwiftUI + AppKit |
| 建置工具 | Swift Package Manager |
| 選單列 | `MenuBarExtra` |
| 疊層視窗 | `NSPanel`（無邊框、浮動） |
| 通知 | `UserNotifications` |
| 音效 | `NSSound` 系統音效 |
| 資料儲存 | `UserDefaults` |
| 資源載入 | `Bundle.main`（直接載入 `Contents/Resources/`） |
| DMG 建置 | shell script + `hdiutil` + `codesign` |

## License

MIT
