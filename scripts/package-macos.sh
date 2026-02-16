#!/bin/bash
set -e

# Package macOS app bundle with Elixir release into a DMG

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HOST_BUILD="$ROOT_DIR/host/build/bin"
RELEASE_DIR="$ROOT_DIR/app/_build/prod/rel/app"
VERSION="${VERSION:-0.1.0}"
OUTPUT_NAME="iterate-live-${VERSION}-macos-$(uname -m)"

echo "==> Packaging $OUTPUT_NAME"

# 1. Build the Go binary
echo "==> Building Go host..."
cd "$ROOT_DIR/host"
CGO_ENABLED=1 go build -o "$HOST_BUILD/iterate-live" .

# 2. Ensure Elixir release exists
if [ ! -d "$RELEASE_DIR" ]; then
    echo "Error: Elixir release not found at $RELEASE_DIR"
    echo "Run 'make build-release' first"
    exit 1
fi

# 3. Assemble .app bundle
APP_BUNDLE="$HOST_BUILD/IterateLive.app"
rm -rf "$APP_BUNDLE"

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$HOST_BUILD/iterate-live" "$APP_BUNDLE/Contents/MacOS/iterate-live"
cp "$ROOT_DIR/host/darwin/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "$ROOT_DIR/host/assets/iterate-logo.png" "$APP_BUNDLE/Contents/Resources/appicon.png"

# Copy Elixir release into bundle
mkdir -p "$APP_BUNDLE/Contents/Resources/rel/app"
cp -R "$RELEASE_DIR"/* "$APP_BUNDLE/Contents/Resources/rel/app/"

echo "==> Assembled $APP_BUNDLE"

# 4. Create output directory
DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"

# 5. Create DMG
DMG_PATH="$DIST_DIR/${OUTPUT_NAME}.dmg"
rm -f "$DMG_PATH"

hdiutil create -volname "Iterate Live" \
    -srcfolder "$APP_BUNDLE" \
    -ov -format UDZO \
    "$DMG_PATH"

echo "==> Created $DMG_PATH"

# 6. Generate checksum
cd "$DIST_DIR"
shasum -a 256 "${OUTPUT_NAME}.dmg" > "${OUTPUT_NAME}.dmg.sha256"
echo "==> Created checksum file"

echo "==> Done!"
ls -la "$DIST_DIR"
