# 開發說明

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
