#!/bin/bash
set -euo pipefail

# ─── Usage ────────────────────────────────────────────────────────────
# ./build.sh                        # build IPA via Sideloadly path
# ./build.sh --skip-clean           # skip cleaning build dir
#
# Output: build/Chronicle.ipa
# Install: drag into Sideloadly, enter Apple ID, hit Start
#
# Note: This build path skips Xcode code signing entirely.
# Sideloadly re-signs the IPA with your Apple ID on install.
# ──────────────────────────────────────────────────────────────────────

SKIP_CLEAN=false
for arg in "$@"; do
    [ "$arg" = "--skip-clean" ] && SKIP_CLEAN=true
done

SCHEME="Chronicle"
PROJECT="Chronicle.xcodeproj"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/Chronicle.xcarchive"
PAYLOAD_DIR="$BUILD_DIR/Payload"
IPA_PATH="$BUILD_DIR/Chronicle.ipa"

# ─── Clean ────────────────────────────────────────────────────────────
if [ "$SKIP_CLEAN" = false ]; then
    echo "==> Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

# ─── Archive (no signing) ─────────────────────────────────────────────
echo ""
echo "==> Archiving (signing disabled)..."
xcodebuild archive \
    -scheme "$SCHEME" \
    -project "$SCRIPT_DIR/$PROJECT" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    AD_HOC_CODE_SIGNING_ALLOWED=YES \
    -quiet

echo "    Archive created."

# ─── Find .app inside archive ─────────────────────────────────────────
APP_PATH=$(find "$ARCHIVE_PATH/Products/Applications" -name "*.app" -maxdepth 1 | head -1)

if [ -z "$APP_PATH" ]; then
    echo "ERROR: Could not find .app in archive. Build may have failed."
    exit 1
fi

echo "    Found: $(basename "$APP_PATH")"

# ─── Package into IPA ─────────────────────────────────────────────────
echo ""
echo "==> Packaging IPA..."
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -r "$APP_PATH" "$PAYLOAD_DIR/"

cd "$BUILD_DIR"
zip -r Chronicle.ipa Payload/ -q
rm -rf Payload/

# ─── Done ─────────────────────────────────────────────────────────────
if [ -f "$IPA_PATH" ]; then
    SIZE=$(du -h "$IPA_PATH" | cut -f1)
    echo ""
    echo "==> Done! $IPA_PATH ($SIZE)"
    echo ""
    echo "    Next steps:"
    echo "    1. Open Sideloadly"
    echo "    2. Drag build/Chronicle.ipa into Sideloadly"
    echo "    3. Enter your Apple ID"
    echo "    4. Hit Start"
    echo "    5. On phone: Settings → General → VPN & Device Management → Trust"
else
    echo "ERROR: IPA not found at $IPA_PATH"
    exit 1
fi
