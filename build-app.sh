#!/bin/bash
set -euo pipefail

PRODUCT="MacTomatoAlarm"
SRC="Sources/$PRODUCT"
BUILD_DIR=".build/app"
APP_BUNDLE="$BUILD_DIR/$PRODUCT.app"
STAGING="$BUILD_DIR/staging"
RESOURCES="$SRC/Resources"

echo "▸ 編譯中..."
swift build -c release

echo "▸ 建立 .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

BIN_PATH="$(swift build -c release --show-bin-path)"
BINARY="$BIN_PATH/$PRODUCT"
cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/$PRODUCT"
cp "$SRC/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "$RESOURCES"/* "$APP_BUNDLE/Contents/Resources/"

# 複製 SwiftPM 產生的資源 bundle，否則 Bundle.module 會在啟動時 fatalError，導致 App 一開啟就閃退
# Swift 6.x 的 resource_bundle_accessor 從 Bundle.main.bundleURL (即 .app 根目錄) 找 bundle，
# 因此需要複製到 .app 根目錄以及 Contents/Resources/ 兩處
RES_BUNDLE="$BIN_PATH/${PRODUCT}_${PRODUCT}.bundle"
if [ -d "$RES_BUNDLE" ]; then
    cp -R "$RES_BUNDLE" "$APP_BUNDLE/"
    cp -R "$RES_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
else
    echo "⚠️  找不到資源 bundle: $RES_BUNDLE" >&2
    exit 1
fi

echo "▸ 用 ad-hoc 簽名..."
codesign -s - "$APP_BUNDLE" 2>/dev/null || true

echo "▸ 產生 DMG 背景圖..."
swiftc -o "$BUILD_DIR/dmg-bg-gen" "Tools/DMGBackground/main.swift" -framework AppKit
"$BUILD_DIR/dmg-bg-gen" "$RESOURCES/icon.icns" "$BUILD_DIR/background.png"

echo "▸ 建立 DMG 暫存目錄..."
rm -rf "$STAGING"
mkdir -p "$STAGING/.background"

cp -R "$APP_BUNDLE" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
cp "$BUILD_DIR/background.png" "$STAGING/.background/"
cp "$RESOURCES/icon.icns" "$STAGING/.VolumeIcon.icns"

echo "▸ 設定視窗佈局..."
ABSOLUTE_STAGING="$(cd "$STAGING" && pwd)"
osascript <<EOF
tell application "Finder"
    set dmgWin to (make new Finder window to (POSIX file "$ABSOLUTE_STAGING" as alias))
    delay 1
    tell dmgWin
        set current view to icon view
        set toolbar visible to false
        set statusbar visible to false
        set bounds to {100, 100, 740, 580}
    end tell
    set opts to icon view options of dmgWin
    tell opts
        set arrangement to not arranged
        set icon size to 80
        set text size to 12
        set background picture to (POSIX file "$ABSOLUTE_STAGING/.background/background.png" as alias)
    end tell
    set position of item "$PRODUCT.app" of dmgWin to {120, 240}
    set position of item "Applications" of dmgWin to {520, 240}
    set position of item ".background" of dmgWin to {-1000, -1000}
    set position of item ".VolumeIcon.icns" of dmgWin to {-1000, -1000}
    delay 0.5
    close dmgWin
end tell
EOF
sleep 1

SetFile -a V "$STAGING/.background"
SetFile -a V "$STAGING/.VolumeIcon.icns"

echo "▸ 建立 DMG..."
DMG_NAME="$PRODUCT.dmg"
DMG_FINAL="$BUILD_DIR/$DMG_NAME"

rm -f "$DMG_FINAL"

hdiutil create -volname "$PRODUCT" -srcfolder "$STAGING" \
  -ov -format UDZO -imagekey zlib-level=9 \
  -scrub "$DMG_FINAL"

echo "▸ 清理暫存..."
rm -f "$BUILD_DIR/dmg-bg-gen" "$BUILD_DIR/background.png"
rm -rf "$STAGING"

echo "▸ 完成！"
echo "   $APP_BUNDLE"
echo "   $DMG_FINAL"
open -R "$DMG_FINAL"
