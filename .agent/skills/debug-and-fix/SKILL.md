---
name: debug-and-fix
description: >
  Quy trình debug khi có lỗi: build error, runtime crash, hoặc UI hiển thị sai.
  Kích hoạt khi có lỗi build, app crash, hoặc behavior không đúng.
---

# Skill: Debug & Fix

## 1. Build Errors

### Đọc Lỗi Đúng Cách

```
error: <mô tả lỗi>
  --> <file>:<line>:<column>
   |
15 | <dòng code lỗi>
   | ^ <chỉ vị trí lỗi>
```

**Chiến lược**:
1. Fix lỗi đầu tiên trong list (các lỗi sau thường là cascade)
2. Đọc file và line number chính xác
3. Hiểu `error:` vs `warning:` — warning không block build

### Lỗi Thường Gặp

```swift
// ❌ "Value of type 'X' has no member 'y'"
// → Gõ sai tên property/method, hoặc dùng wrong type
// Fix: Kiểm tra lại tên và type

// ❌ "Cannot convert value of type 'X' to specified type 'Y'"
// → Type mismatch
// Fix: Thêm as? hoặc as!, hoặc sửa type

// ❌ "Use of unresolved identifier 'x'"
// → Dùng biến chưa khai báo, hoặc sai scope
// Fix: Kiểm tra khai báo và scope

// ❌ "Expression is unused"
// → Tính toán kết quả nhưng không dùng
// Fix: Gán vào biến hoặc xóa dòng đó
```

---

## 2. SDK / Compiler Errors

### SDK Mismatch (đã gặp)
```
error: failed to build module 'Swift'; this SDK is not supported by the compiler
```
**Fix**: Đảm bảo `SDK_PATH` trong `build.sh` khớp với Swift compiler version.
```bash
# Kiểm tra Swift version
swift --version

# Kiểm tra SDKs có sẵn
ls /Library/Developer/CommandLineTools/SDKs/
```

---

## 3. Runtime Issues (App Crash / Behavior Sai)

### App Không Xuất Hiện Trên Menu Bar
```bash
# Kill process cũ trước
pkill -f MacStats
open MacStats.app

# Xem console logs
log stream --predicate 'process == "MacStats"' --level debug
```

### SMC Temperature Trả Về 0 hoặc Nil
- Nguyên nhân: Sensor key không active trên máy này
- Fix: Không cần fix — `StatusBarView` đã handle với `"--"` display
- **Không sửa `SMC.swift`**

### Settings Không Persist
```swift
// Kiểm tra key name spelling
UserDefaults.standard.synchronize()  // Force write (debug only)
```

---

## 4. UI Hiển Thị Sai

### Màu Không Đúng Theo Dark/Light Mode
```swift
// Trong draw(), luôn kiểm tra effectiveAppearance
let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
```

### Width Menu Bar Bị Sai
```swift
// Phải tính qua calculateWidth(), không hardcode
let width = UnifiedStatsView.calculateWidth(showNetwork: showNetworkSpeeds, showTemperature: showCPUTemperature)
statusItem.length = width
```

---

## 5. Quy Trình Debug Chuẩn

```
1. Đọc lỗi đầy đủ (không đọc vội)
2. Xác định file và line
3. Giải thích lỗi cho developer bằng tiếng Việt
4. Đề xuất 1-2 cách fix (không tự fix ngay)
5. Grill nếu không chắc nguyên nhân
6. Fix → Build → Verify
7. Ghi vào memory/bugs.md nếu là bug thú vị
```

---

## 6. Memory/Bugs Template

Sau khi fix, ghi vào `.agent/memory/bugs.md`:

```markdown
## [Date] Bug: <mô tả ngắn>

**Triệu chứng**: App crash khi click menu

**Nguyên nhân**: `representedObject` là nil vì...

**Fix**: Thêm guard let trước khi cast

**File**: `AppDelegate.swift` dòng 315

**Lesson**: Luôn dùng `as?` không dùng `as!` với representedObject
```
