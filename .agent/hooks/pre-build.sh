#!/bin/bash
# Hook: pre-build
# Chạy TRƯỚC KHI build để validate code
# Được gọi tự động bởi agent trước mỗi bash build.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

echo "🔍 [pre-build] Checking Swift files..."

# 1. Kiểm tra không có force unwrap trong file mới
FORCE_UNWRAP_COUNT=$(grep -rn " as! " AppDelegate.swift StatusBarView.swift 2>/dev/null | grep -v "//.*as!" | wc -l | tr -d ' ')
if [ "$FORCE_UNWRAP_COUNT" -gt "0" ]; then
    echo "⚠️  Warning: Found $FORCE_UNWRAP_COUNT force unwrap(s). Consider using 'as?' with guard/if let."
    grep -rn " as! " AppDelegate.swift StatusBarView.swift 2>/dev/null | grep -v "//.*as!" || true
fi

# 2. Kiểm tra file SMC.swift không bị sửa (quá rủi ro)
SMC_HASH_FILE=".agent/.smc_checksum"
CURRENT_SMC_HASH=$(md5 -q SMC.swift 2>/dev/null || md5sum SMC.swift 2>/dev/null | awk '{print $1}')
if [ -f "$SMC_HASH_FILE" ]; then
    SAVED_HASH=$(cat "$SMC_HASH_FILE")
    if [ "$CURRENT_SMC_HASH" != "$SAVED_HASH" ]; then
        echo "⚠️  WARNING: SMC.swift has been modified!"
        echo "   SMC.swift is low-level IOKit code — changes are high-risk."
        echo "   If intentional, run: echo '$CURRENT_SMC_HASH' > .agent/.smc_checksum"
    fi
else
    echo "$CURRENT_SMC_HASH" > "$SMC_HASH_FILE"
    echo "📌 SMC.swift checksum saved."
fi

# 3. Kiểm tra SDK path tồn tại
SDK_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk"
if [ ! -d "$SDK_PATH" ]; then
    echo "❌ ERROR: SDK not found at $SDK_PATH"
    echo "   Available SDKs:"
    ls /Library/Developer/CommandLineTools/SDKs/ 2>/dev/null || echo "   (none found)"
    echo "   Update SDK_PATH in build.sh to match an available SDK."
    exit 1
fi

echo "✅ [pre-build] All checks passed."
