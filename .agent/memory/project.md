# Project Memory — mac-stats Fork

## 🏗️ Architectural Decisions

### 2026-08-07: SDK Fix
- **Vấn đề**: Swift 6.2.4 không tương thích với default SDK symlink
- **Giải pháp**: Hardcode `SDK_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk"` trong `build.sh`
- **Lý do**: Swift 6.2.4 (swiftlang-6.2.4.1.4) cần SDK khớp với compiler version

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

### 🚧 In Progress
- [ ] Network Display Unit Setting
- [ ] Threshold Settings UI
- [ ] Compact display mode
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

---

## 📝 Learning Notes (Swift Concepts Learned)

*Section này ghi lại những gì owner đã học được qua từng feature*

### Session 1 (2026-08-07)
- Hiểu cấu trúc app: main.swift → AppDelegate → StatsEngine + StatusBarView
- Biết cách build bằng `swiftc` không cần Xcode
- Hiểu `UserDefaults` là nơi lưu settings app
- Hiểu `@objc` và `#selector` là cách AppKit gọi functions

---

## 🔄 Build History
*(Auto-updated bởi post-build.sh hook)*
