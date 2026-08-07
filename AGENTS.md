# AGENTS.md — mac-stats (Personal Fork)

> **README cho tất cả AI agents** (Antigravity, Claude Code, Cursor, Codex, OpenCode, GitHub Copilot...).
> Đây là nguồn sự thật duy nhất. Đọc toàn bộ file này trước khi làm bất cứ điều gì.

---

## 🎯 Project Context

**mac-stats** là macOS Menu Bar Monitor app, Swift thuần, không Xcode.
Fork cá nhân từ [openhoangnc/mac-stats](https://github.com/openhoangnc/mac-stats) (MIT License).

**Owner**: Người dùng cá nhân, đang học Swift qua việc làm thực tế.
**Remote repo**: Chưa có — chỉ làm local. Không push lên bất kỳ remote nào khi chưa được yêu cầu.

---

## 🚨 MANDATORY WORKFLOW — ĐÂY LÀ QUY TRÌNH BẮT BUỘC

**Mọi AI agent đều phải tuân theo workflow này, không có ngoại lệ:**

```
1. GRILL    → Hỏi developer đến khi hiểu rõ mong muốn thực sự
2. PLAN     → Grill tiếp cho đến khi chốt được plan cụ thể
3. BRANCH   → Tạo nhánh git TRƯỚC KHI viết bất kỳ dòng code nào
4. IMPLEMENT→ Implement từng bước nhỏ, giải thích tại sao trước khi code
5. BUILD    → Tự chạy `bash build.sh` sau mỗi thay đổi
6. TEST     → Xác nhận app chạy đúng
7. COMMIT   → Commit với Conventional Commits format
8. MEMORY   → Cập nhật `.agent/memory/` sau mỗi commit
9. MERGE    → Merge vào main khi test xong xuôi
```

> ⚠️ **KHÔNG BAO GIỜ code trực tiếp trên nhánh `main`.**
> ⚠️ **KHÔNG BAO GIỜ bỏ qua bước GRILL — dù yêu cầu có vẻ đơn giản.**

Chi tiết xem: [`.agent/skills/feature-planning-workflow/SKILL.md`](.agent/skills/feature-planning-workflow/SKILL.md)

---

## 🛑 CRITICAL CHANGES — DỪNG VÀ HỎI USER

Nếu một thay đổi thuộc bất kỳ loại nào dưới đây, **AI phải dừng lại và hỏi user trước**:

- Sửa `SMC.swift` (low-level IOKit, rất dễ break)
- Sửa `Info.plist` (đặc biệt `LSUIElement`)
- Xóa hoặc thay đổi cấu trúc `.app` bundle
- Thay đổi deployment target (macOS 11 là minimum)
- Thay đổi SDK path trong `build.sh`
- Thay AppKit bằng SwiftUI hoặc thêm bất kỳ external dependency
- Bất kỳ hành động nào tác động lên filesystem ngoài project folder
- Bất kỳ hành động nào tác động lên máy local (install, uninstall, registry)

---

## 🗣️ Giao Tiếp

- **Giải thích**: Tiếng Việt — tại sao làm thế này
- **Code & Comments**: Tiếng Anh
- **Phong cách**: Giải thích `tại sao` trước, rồi mới đưa ra code
- **Ambiguity**: Grill cho đến khi chốt plan, không tự quyết định
- **Code mới**: Sạch, không comment thừa — nhưng giải thích rõ ràng trong chat

---

## 🗂️ Cấu Trúc Project

```
mac-stats/
├── main.swift          # Entry point: CLI flags, duplicate prevention
├── AppDelegate.swift   # App lifecycle, timer, menu, settings
├── StatsEngine.swift   # Data collection: CPU/RAM/Network/Processes
├── StatusBarView.swift # UI rendering: menu bar display
├── SMC.swift           # ⛔ Temperature via IOKit/SMC — KHÔNG SỬA
├── build.sh            # Build script (không cần Xcode)
├── install.sh          # One-line install
├── uninstall.sh        # Clean uninstall
├── Info.plist          # Bundle metadata — CẨN THẬN KHI SỬA
├── AGENTS.md           # ← File này
└── .agent/
    ├── rules/          # Quy tắc development
    ├── hooks/          # Pre/post build scripts
    ├── skills/         # Hướng dẫn implement từng tính năng
    └── memory/         # Ghi nhớ giữa các sessions
```

---

## ⚙️ Build & Run

```bash
# Build (universal binary arm64 + x86_64)
bash build.sh

# Mở app
open MacStats.app

# Build + install vào /Applications
./install.sh

# Uninstall
./uninstall.sh
```

> **SDK**: `/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk` — đã hardcode trong `build.sh`.

---

## 📐 Coding Standards

- **Swift 5.x** (không dùng Swift 6 strict concurrency)
- Ưu tiên `guard let` over `if let`
- `// MARK: -` để phân vùng code
- Tên biến: `camelCase`, tên hàm: `động từ + danh từ`

Chi tiết xem: [`.agent/rules/swift-style.md`](.agent/rules/swift-style.md)

---

## 🚫 KHÔNG được làm (Hard Rules)

- ❌ Thêm third-party dependencies
- ❌ Dùng Xcode project files (`.xcodeproj`)
- ❌ Import SwiftUI
- ❌ Sửa `SMC.swift`
- ❌ Thay đổi `LSUIElement=true` trong `Info.plist`
- ❌ Commit build artifacts (`MacStats.app`, `*_arm64`, `*_x86_64`)
- ❌ Viết code block dài quá 50 dòng trong một lần
- ❌ Code trực tiếp trên nhánh `main`
- ❌ Push lên remote khi chưa được yêu cầu

---

## ✅ Definition of Done

Một feature được coi là hoàn thành khi:
1. `bash build.sh` không có error/warning mới
2. App launch, icon xuất hiện trên menu bar
3. Tính năng hoạt động đúng như plan đã chốt
4. Settings persist sau khi restart app
5. Dark mode và Light mode đều hiển thị đúng
6. Đã commit với Conventional Commits message
7. Đã cập nhật `.agent/memory/` sau commit
8. Đã merge vào `main`

---

## 🎨 Personalization Goals (Priority Order)

1. **Custom Color Thresholds** — Discrete colors (xanh/vàng/đỏ) với ngưỡng tùy chỉnh
2. **Compact Display** — Tốn ít pixel nhất trên menu bar
3. **Expand later** — Notification alerts, history chart, GPU... (chưa cần ngay)

---

## 🔑 Key Files Reference

| Muốn thay đổi gì | Sửa file nào | Dòng quan trọng |
|---|---|---|
| Màu sắc indicators | `StatusBarView.swift` | `colorForUsage()`, `colorForTemperature()` |
| Thêm settings menu | `AppDelegate.swift` | `showMenu()` ~L91 |
| Thu thập data mới | `StatsEngine.swift` | Thêm `fetchXxxStats()` |
| Layout menu bar | `StatusBarView.swift` | `draw()` ~L172, section widths |
| Build configuration | `build.sh` | SDK path, flags |

---

## 📚 Skills Index

| Skill | Khi nào dùng |
|---|---|
| [`feature-planning-workflow`](.agent/skills/feature-planning-workflow/SKILL.md) | Bắt đầu bất kỳ feature nào |
| [`git-workflow`](.agent/skills/git-workflow/SKILL.md) | Branch, commit, merge |
| [`swift-menubar-basics`](.agent/skills/swift-menubar-basics/SKILL.md) | Hỏi về NSColor, UserDefaults, AppKit... |
| [`custom-threshold-feature`](.agent/skills/custom-threshold-feature/SKILL.md) | Implement warn/critical color levels |
| [`compact-display`](.agent/skills/compact-display/SKILL.md) | Implement compact/minimal mode |
| [`debug-and-fix`](.agent/skills/debug-and-fix/SKILL.md) | Khi có lỗi build hoặc runtime |

---

## 🐛 Known Issues

- **SDK mismatch**: Đã fix — hardcode SDK path trong `build.sh`
- **Top Processes dùng subprocess**: Acceptable — chỉ chạy khi mở menu
- **Network chỉ đếm "en" interfaces**: By design — VPN/utun không tính
