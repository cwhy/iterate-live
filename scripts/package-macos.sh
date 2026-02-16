#!/bin/bash
set -e

# Package macOS app bundle with Elixir release into a DMG
# Includes code signing and notarization for distribution

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HOST_BUILD="$ROOT_DIR/host/build/bin"
RELEASE_DIR="$ROOT_DIR/app/_build/prod/rel/app"
VERSION="${VERSION:-0.1.0}"
OUTPUT_NAME="iterate-live-${VERSION}-macos-$(uname -m)"

# Code signing identity - set this to your Developer ID
# Find yours with: security find-identity -v -p codesigning
SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application}"
ENTITLEMENTS="$ROOT_DIR/host/darwin/entitlements.plist"

# Notarization credentials profile name (created with notarytool store-credentials)
NOTARY_PROFILE="${NOTARY_PROFILE:-AC_PASSWORD}"

echo "==> Packaging $OUTPUT_NAME"

# 1. Generate icons and build Go binary
echo "==> Generating icons..."
mkdir -p "$ROOT_DIR/host/assets"
qlmanage -t -s 44 -o "$ROOT_DIR/host/assets/" "$ROOT_DIR/assets/iterate-logo.svg" 2>/dev/null
mv "$ROOT_DIR/host/assets/iterate-logo.svg.png" "$ROOT_DIR/host/assets/tray-icon.png"

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

# 4. Code sign the app bundle
echo "==> Code signing..."

# Sign ALL Mach-O binaries in the Elixir release (executables, .so, .dylib)
# Use 'file' to detect Mach-O binaries rather than relying on file extensions
find "$APP_BUNDLE/Contents/Resources/rel" -type f -print0 | while IFS= read -r -d '' file; do
    # Check if it's a Mach-O binary
    if file "$file" | grep -q "Mach-O"; then
        echo "Signing: $file"
        codesign --force --options runtime --timestamp \
            --sign "$SIGN_IDENTITY" \
            --entitlements "$ENTITLEMENTS" \
            "$file" || echo "Warning: Could not sign $file"
    fi
done

# Sign the main Go binary
codesign --force --options runtime --timestamp \
    --sign "$SIGN_IDENTITY" \
    --entitlements "$ENTITLEMENTS" \
    "$APP_BUNDLE/Contents/MacOS/iterate-live"

# Sign the entire app bundle (must be done last, signs the bundle itself)
codesign --force --options runtime --timestamp \
    --sign "$SIGN_IDENTITY" \
    --entitlements "$ENTITLEMENTS" \
    "$APP_BUNDLE"

# Verify signature
echo "==> Verifying signature..."
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

# 5. Create output directory
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

# 6. Sign the DMG
codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG_PATH"

# 7. Notarize the DMG
echo "==> Submitting for notarization (this may take a few minutes)..."
if [ -n "$APPLE_ID" ] && [ -n "$APPLE_APP_PASSWORD" ] && [ -n "$APPLE_TEAM_ID" ]; then
    # CI mode: use environment variables
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_APP_PASSWORD" \
        --wait
else
    # Local mode: use keychain profile
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait
fi

# 8. Staple the notarization ticket
echo "==> Stapling notarization ticket..."
xcrun stapler staple "$DMG_PATH"

# 9. Generate checksum
cd "$DIST_DIR"
shasum -a 256 "${OUTPUT_NAME}.dmg" > "${OUTPUT_NAME}.dmg.sha256"
echo "==> Created checksum file"

echo "==> Done!"
ls -la "$DIST_DIR"
