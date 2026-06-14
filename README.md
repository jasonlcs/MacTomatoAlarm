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
- **螢幕休眠保護** — 螢幕休眠時自動暫停，喚醒後繼續並短暫滑出倒數提示
- **每日統計** — 自動記錄每日完成 session 數
- **俐落 DMG** — 拖曳到 Applications 即可安裝

## 安裝

1. 從 [Releases](https://github.com/jasonlcs/MacTomatoAlarm/releases) 下載最新 `MacTomatoAlarm.dmg`
2. 打開 DMG，將 `MacTomatoAlarm.app` 拖曳到 `Applications` 資料夾
3. 首次執行時，若出現「無法驗證是否為惡意軟體」，對 App **按右鍵 → 打開** 即可（僅需一次）

## 疑難排解

| 問題 | 解決方法 |
|---|---|
| App 打開後沒有反應 / 閃退 | 確認 macOS ≥ 14；若從 DMG 安裝，務必先複製到 Applications 再執行 |
| 「無法打開，應丟到垃圾桶」 | 右鍵點擊 App →「打開」；或在「系統設定 → 隱私權與安全性」允許 |
| 選單列沒有出現圖示 | 系統可能隱藏了選單列 icon，到「系統設定 → 控制中心」調整選單列項目 |
| 通知沒出現 | 確認「系統設定 → 通知」中 MacTomatoAlarm 的通知已開啟 |
| 螢幕喚醒後計時器狀態不如預期 | 只有因螢幕休眠而自動暫停的計時器會在喚醒後自動繼續；手動暫停不會被喚醒事件恢復 |

## 開發

想自行建置、了解技術架構或設定 CI 簽名，請見 [DEVELOPMENT.md](DEVELOPMENT.md)。

## License

MIT
