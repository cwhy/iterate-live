#!/bin/bash
set -e

# Package macOS app bundle with Elixir release

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
APP_BUNDLE="$ROOT_DIR/host/build/bin/host.app"
RELEASE_DIR="$ROOT_DIR/app/_build/prod/rel/app"
VERSION="${VERSION:-0.1.0}"
OUTPUT_NAME="iterate-live-${VERSION}-macos-$(uname -m)"

echo "==> Packaging $OUTPUT_NAME"

# 1. Ensure builds exist
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: App bundle not found at $APP_BUNDLE"
    echo "Run 'make build' first"
    exit 1
fi

if [ ! -d "$RELEASE_DIR" ]; then
    echo "Error: Elixir release not found at $RELEASE_DIR"
    echo "Run 'make build-release' first"
    exit 1
fi

# 2. Copy Elixir release into app bundle
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"
mkdir -p "$RESOURCES_DIR/rel/app"
cp -R "$RELEASE_DIR"/* "$RESOURCES_DIR/rel/app/"

echo "==> Copied Elixir release to $RESOURCES_DIR/rel/"

# 3. Create output directory
DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"

# 4. Create DMG
DMG_PATH="$DIST_DIR/${OUTPUT_NAME}.dmg"
rm -f "$DMG_PATH"

hdiutil create -volname "Iterate Live" \
    -srcfolder "$APP_BUNDLE" \
    -ov -format UDZO \
    "$DMG_PATH"

echo "==> Created $DMG_PATH"

# 5. Generate checksum
cd "$DIST_DIR"
shasum -a 256 "${OUTPUT_NAME}.dmg" > "${OUTPUT_NAME}.dmg.sha256"
echo "==> Created checksum file"

echo "==> Done!"
ls -la "$DIST_DIR"
