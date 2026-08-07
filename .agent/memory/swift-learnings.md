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

## Session 2 — 2026-08-07: Critical Bugs & Optimizations

### Concepts Learned

**Timer RunLoop Modes**
- `scheduledTimer` = tạo Timer + add vào RunLoop `.default` tự động
- `.common` mode bao gồm `.default` + `.eventTracking` → timer fire cả khi user đang drag
- Muốn dùng `.common`: tạo timer bằng `Timer(timeInterval:...)` rồi `RunLoop.current.add(t, forMode: .common)`
- KHÔNG dùng `scheduledTimer` + `add(.common)` → fire 2 lần!

**Integer Overflow Safety**
- `Int32` trừ nhau khi counter wrap → kết quả âm → cast `UInt64` → rác
- Giải pháp: widen sang `Int64` trước khi trừ, rồi `max(0, delta)`
- Tương tự cho network: `UInt32` overflow khi vượt 4GB → detect wrap-around

**SMC / IOKit**
- `IOConnectCallStructMethod` là syscall vào kernel — nặng, cần minimize
- `keyInfo` (dataSize, dataType) không đổi cho cùng key → cache được
- SMC trả bytes big-endian, host là little-endian → phải swap

**UserDefaults Computed Property**
- Dùng computed property `get/set` thay vì stored property → auto-persist
- `UserDefaults.standard.double(forKey:)` trả 0.0 nếu key chưa có → cần guard

**NSAttributedString Cache**
- So sánh raw `Double` nhanh hơn format String rồi compare String
- Chỉ gọi `String(format:)` khi value thực sự thay đổi → giảm allocation

---

## Session 3 — [Date]: [Feature Name]

*[AI sẽ điền vào đây sau mỗi commit]*
