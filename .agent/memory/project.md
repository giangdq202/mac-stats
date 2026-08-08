# Project Memory — mac-stats Fork

## 🏗️ Architectural Decisions

### 2026-08-07: SDK Fix
- **Vấn đề**: Swift 6.2.4 không tương thích với default SDK symlink
- **Giải pháp**: Hardcode `SDK_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk"` trong `build.sh`
- **Lý do**: Swift 6.2.4 (swiftlang-6.2.4.1.4) cần SDK khớp với compiler version

### 2026-08-08: Rebrand & Customization
- **App Name**: Đổi từ MacStats sang MeMo (Menu Monitor)
- **Credit**: Ghi công `openhoangnc/mac-stats`, thêm modifier `giangdq202`
- **Icon**: Thay đổi thành speedometer icon hiện đại
- **Release Scripts**: Fix `install.sh` download zip trỏ đúng repo giangdq202 và rename build artifacts sang `MeMo.zip` trong `release.yml`

### 2026-08-07: Fork Setup
- **Nguồn gốc**: Fork từ openhoangnc/mac-stats (MIT License)
- **Mục tiêu**: Personalization — custom thresholds, compact display
- **Approach**: Modify trực tiếp source files, không dùng Swift Package Manager
- **Build**: Universal binary (arm64 + x86_64) qua `build.sh`

---

## 📦 Dependencies

| Dependency | Version | Ghi chú |
|---|---|---|
| Swift | 6.2.4 | Cài qua Xcode Command Line Tools |
| macOS SDK | 15.5 | Path: `/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk` |
| AppKit | system | UI framework |
| IOKit | system | SMC temperature sensor |
| Foundation | system | Core utilities |

**Zero external dependencies** — không CocoaPods, không SPM packages.

---

## 🎯 Features Roadmap

### ✅ Done
- [x] Fork setup & build working
- [x] AGENTS.md + .agent folder structure
- [x] VS Code configurations (tasks, launch, settings)
- [x] Critical bugs fix: timer double-fire, CPU overflow, SMC guard, interval persist
- [x] Optimizations: SMC keyInfo cache, draw() cache, Float endian fix, codesign cleanup
- [x] Custom color thresholds (warn/critical levels)
- [x] Discrete 4-level colors (Green/Yellow/Orange/Red)
- [x] Enhanced Dropdown Menu (system summary, progress bars)
- [x] Network Display Unit Setting
- [x] Optimal Hardcoded Thresholds (Removed UI)
- [x] Removed Display Mode (relying on toggles)
- [x] Network Up/Down Icons
- [x] Dynamic Dropdown Menu & Update Interval (ms)
- [x] Rebrand app to MeMo, add speedometer icon

### 🐞 Bugfix Backlog (from Deep Inspection 2026-08-08)
- [x] **P1** — Fahrenheit trong menu hiện giá trị Celsius gắn nhãn °F → PR #8
- [x] **P2** — RAM color cache không invalidate khi `_memPercent` thay đổi → PR #9
- [x] **P3** — Menu updaters bị clear ngay sau performClick → PR #10
- [x] **P4** — Network spike giả khi interface disconnect/reconnect → PR #11
- [x] **P5+P7** — sp78 signed parse + SMC fallback float remove → PR #12
- [x] **P6** — Deduplicate formatSpeed/formatNetworkSpeed → PR #13

### 🚧 In Progress
- [x] Apple Silicon only app (arm64 build)
- [x] Temperature grouped by clusters (P-Cores, E-Cores, GPU) in Dropdown
- [ ] (Future) Notification alerts
- [ ] (Future) History sparkline chart

---

## 🐛 Known Issues

| Issue | Status | Workaround |
|---|---|---|
| SDK version mismatch | ✅ Fixed | Hardcoded SDK path in build.sh |
| Network: ignores VPN/utun | Open | By design — chỉ "en" interfaces |
| Top Processes: subprocess overhead | Open | Acceptable — only on menu open |
| Timer fired 2x per interval | ✅ Fixed | Timer now uses unscheduled Timer() + RunLoop.add(.common) |
| CPU delta integer overflow | ✅ Fixed | Cast Int32→Int64 before subtraction, clamp to 0 |
| SMC conn=0 wasted syscalls | ✅ Fixed | guard conn != 0 in getValue() |
| updateInterval not persisted | ✅ Fixed | Now stored in UserDefaults |
| Fahrenheit in menu shows Celsius value | ✅ Fixed | PR #8 — added C→F conversion |
| RAM color stale when % crosses threshold | ✅ Fixed | PR #9 — added memPercent to cache key |
| Menu values freeze while open | ✅ Fixed | PR #10 — defer cleanup to menuDidClose |
| Network spike on interface change | ✅ Fixed | PR #11 — clamp delta to 0 |
| sp78 signed parse incorrect | ✅ Fixed | PR #12 — use Int16 big-endian |
| SMC fallback float false positive | ✅ Fixed | PR #12 — removed unsafe default case |
| Duplicated format logic | ✅ Fixed | PR #13 — shared formatNetworkSpeed() |

---

## 📝 Learning Notes (Swift Concepts Learned)

*Section này ghi lại những gì owner đã học được qua từng feature*

### Session 1 (2026-08-07)
- Hiểu cấu trúc app: main.swift → AppDelegate → StatsEngine + StatusBarView
- Biết cách build bằng `swiftc` không cần Xcode
- Hiểu `UserDefaults` là nơi lưu settings app
- Hiểu `@objc` và `#selector` là cách AppKit gọi functions

### Session 2 (2026-08-08)
- `NSMenuDelegate.menuDidClose` — cách detect khi dropdown menu đóng
- Cache invalidation strategy: mọi giá trị ảnh hưởng đến render đều phải là cache key
- `sp78` SMC format: signed fixed-point, dùng `Int16` big-endian
- Free function vs static method: dùng free function cho shared logic giữa các class
- Network counter: không giả định wrap-around khi tổng nhiều interface

---

## 🔄 Build History
*(Auto-updated bởi post-build.sh hook)*
