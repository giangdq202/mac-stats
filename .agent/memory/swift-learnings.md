# Swift Learnings — mac-stats Project

> Ghi lại những Swift concepts đã học qua từng feature.
> AI cập nhật file này sau mỗi commit.

---

## Session 1 — 2026-08-07: Project Setup

### Concepts Learned

**App Architecture**
- macOS Menu Bar app không có Window — chỉ có `NSStatusItem` trên menu bar
- `NSApp.setActivationPolicy(.accessory)` → ẩn icon khỏi Dock và Command-Tab
- `LSUIElement = true` trong `Info.plist` → app chạy như background accessory

**Entry Point**
- `NSApplicationMain` bị bỏ qua → dùng `NSApplication.shared` manual để tránh load NIB
- `app.delegate = delegate; app.run()` → khởi động event loop

**Timer**
- `Timer.scheduledTimer(withTimeInterval:repeats:)` → gọi function định kỳ
- `timer.tolerance = 0.25 * interval` → cho macOS coalesce với timer khác (tiết kiệm pin)
- `[weak self]` trong closure → tránh memory retain cycle

**UserDefaults**
- Lưu settings đơn giản với `UserDefaults.standard.set(value, forKey: "key")`
- Đọc với type-safe: `object(forKey:) as? Bool ?? defaultValue`
- Thay đổi persist sau khi quit và reopen app

**Build System**
- `swiftc` compile trực tiếp không cần Xcode project
- `lipo -create arm64 x86_64 -output universal` → universal binary
- `-Osize -wmo -dead_strip` → optimize size, compile as whole module

**SDK Fix**
- Swift 6.2.4 cần SDK khớp version
- Fix: hardcode `-sdk /Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk` trong build.sh

---

## Session 2 — [Date]: [Feature Name]

*[AI sẽ điền vào đây sau mỗi commit]*
