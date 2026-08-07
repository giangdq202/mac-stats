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

---

## 2026-08-07: Timer Double-Fire

**Triệu chứng**: `updateStats()` chạy gấp đôi tần suất mong muốn → CPU waste, battery drain
**Nguyên nhân**: `scheduledTimer` auto-adds timer vào RunLoop mode `.default`. Code sau đó lại `RunLoop.current.add(timer!, forMode: .common)` → timer registered in both modes. Vì `.common` bao gồm `.default`, timer fires 2x.
**Fix**: Dùng `Timer(timeInterval:...)` (unscheduled) rồi `RunLoop.current.add(t, forMode: .common)` — chỉ 1 lần.
**File**: `AppDelegate.swift` dòng 56-66
**Lesson**: `scheduledTimer` = tạo + add RunLoop. Nếu muốn custom mode, dùng `Timer()` constructor + manual add.

---

## 2026-08-07: CPU Delta Integer Overflow

**Triệu chứng**: CPU hiển thị 100% giả hoặc giá trị rác khi counter wrap around
**Nguyên nhân**: `cpuInfo[x] - prevCpuInfo[x]` là phép trừ `Int32`. Khi counter overflow, kết quả âm, cast sang `UInt64` → giá trị khổng lồ (~2^63).
**Fix**: Cast mỗi operand sang `Int64` trước khi trừ, rồi `max(0, delta)` để clamp.
**File**: `StatsEngine.swift` dòng 168-174
**Lesson**: Khi trừ unsigned/signed integers rồi cast type, luôn widen type trước khi trừ.

---

## 2026-08-07: SMC Connection Not Guarded

**Triệu chứng**: Khi SMC init fail (conn=0), mỗi 2 giây vẫn gọi 100+ syscalls vô ích vào kernel
**Nguyên nhân**: `SMC.init()` fail silently (return sớm, conn vẫn = 0). `getValue()` không kiểm tra conn trước khi gọi `IOConnectCallStructMethod`.
**Fix**: Thêm `guard conn != 0 else { return nil }` ở đầu `getValue()`.
**File**: `SMC.swift` dòng 149
**Lesson**: Khi init có thể fail, mọi method public phải guard state validity.

---

## 2026-08-07: Float Byte-Order in SMC

**Triệu chứng**: Nhiệt độ sai cho sensors dùng type `"flt "` (IEEE 754 float)
**Nguyên nhân**: SMC trả bytes big-endian, nhưng `load(as: Float.self)` đọc host-endian (little-endian trên cả Intel và Apple Silicon).
**Fix**: Swap bytes [3,2,1,0] trước khi load.
**File**: `SMC.swift` dòng 100-107
**Lesson**: Hardware interfaces thường dùng big-endian. Luôn xác nhận byte order trước khi dùng `load(as:)`.
