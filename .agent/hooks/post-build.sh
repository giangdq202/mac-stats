#!/bin/bash
# Hook: post-build
# Chạy SAU KHI build thành công
# Báo cáo kết quả và kích thước binary

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

APP_BUNDLE="MacStats.app"
BINARY="$APP_BUNDLE/Contents/MacOS/MacStats"

if [ ! -f "$BINARY" ]; then
    echo "❌ [post-build] Binary not found: $BINARY"
    exit 1
fi

echo ""
echo "📊 [post-build] Build Report"
echo "─────────────────────────────"

# Kích thước binary
BINARY_SIZE=$(du -sh "$BINARY" 2>/dev/null | awk '{print $1}')
APP_SIZE=$(du -sh "$APP_BUNDLE" 2>/dev/null | awk '{print $1}')
echo "  Binary size : $BINARY_SIZE"
echo "  App bundle  : $APP_SIZE"

# Architecture check
echo "  Architectures:"
lipo -info "$BINARY" 2>/dev/null | sed 's/^/    /'

# Code signature
echo "  Code sign   :"
codesign -dv "$APP_BUNDLE" 2>&1 | grep -E "Authority|TeamIdentifier|Signature" | sed 's/^/    /' || echo "    (ad-hoc)"

echo "─────────────────────────────"
echo "✅ Build successful! Run with: open $APP_BUNDLE"
echo ""

# Lưu build log
LOG_FILE=".agent/memory/build_history.log"
mkdir -p ".agent/memory"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Build OK — binary=$BINARY_SIZE app=$APP_SIZE" >> "$LOG_FILE"
