#!/bin/bash
set -euo pipefail

PRODUCT="MacTomatoAlarm"
BUILD_DIR=".build/app"
APP_BUNDLE="$BUILD_DIR/$PRODUCT.app"

echo "▸ 編譯中..."
swift build -c release

echo "▸ 建立 .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

BINARY="$(swift build -c release --show-bin-path)/$PRODUCT"
cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/$PRODUCT"

cp "Sources/$PRODUCT/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp Sources/$PRODUCT/Resources/* "$APP_BUNDLE/Contents/Resources/"

echo "▸ 完成！"
echo "   $APP_BUNDLE"
open -R "$APP_BUNDLE"
