# Bug Log — mac-stats Project

> AI cập nhật file này sau mỗi bug được tìm và fix.
> Format chuẩn giúp học từ lỗi cũ.

---

## Template

```markdown
## [YYYY-MM-DD] Bug: <tên ngắn gọn>

**Triệu chứng**: [Mô tả điều gì xảy ra sai]
**Nguyên nhân**: [Root cause]
**Fix**: [Cách đã fix]
**File & Line**: [`filename.swift` dòng X]
**Lesson**: [Rút ra gì cho lần sau]
```

---

## 2026-08-07: SDK Version Mismatch

**Triệu chứng**: `bash build.sh` báo lỗi:
```
error: failed to build module 'Swift'; this SDK is not supported by the compiler
```

**Nguyên nhân**: Swift 6.2.4 (compiler mới) nhưng `xcode-select` trỏ đến SDK cũ hơn.
SDK symlink (`MacOSX.sdk`) trỏ vào version không match với compiler.

**Fix**: Hardcode SDK path trong `build.sh`:
```bash
SDK_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk"
COMMON_FLAGS=(-Osize -wmo -module-name MacStats -sdk "$SDK_PATH" ...)
```

**File**: `build.sh` dòng 21-22

**Lesson**: 
- Khi update Command Line Tools, luôn kiểm tra `swift --version` vs SDK version
- `xcrun --show-sdk-path --sdk macosx` → xem SDK đang active
- `ls /Library/Developer/CommandLineTools/SDKs/` → xem SDKs có sẵn
