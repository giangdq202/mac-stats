# Rules: Critical Change Guard

## Định Nghĩa Critical Change

Trước khi thực hiện bất kỳ hành động nào thuộc danh sách dưới đây,
AI **PHẢI dừng lại và hỏi developer xác nhận**. Không có ngoại lệ.

---

## Danh Sách Critical Changes

### 🔴 Mức Cao Nhất — Hỏi Và Giải Thích Rủi Ro

1. **Sửa `SMC.swift`**
   - Lý do: Low-level IOKit, sai 1 byte có thể crash app hoặc gây kernel panic
   - Phải nói rõ: "File này tôi không recommend sửa vì..."

2. **Sửa `Info.plist`**
   - Đặc biệt: `LSUIElement` (ẩn/hiện Dock icon)
   - Đặc biệt: `CFBundleIdentifier` (ảnh hưởng UserDefaults, LaunchAgent)

3. **Xóa hoặc restructure `.app` bundle**
   - Xóa `Contents/MacOS/`, `Contents/Resources/`

4. **Thay AppKit bằng SwiftUI**
   - Đây là architecture change lớn, cần plan riêng

5. **Thêm external dependency** (CocoaPods, SPM)
   - Project phải giữ zero-dependency

---

### 🟠 Mức Trung Bình — Hỏi Trước Khi Làm

6. **Thay đổi deployment target** (xuống dưới macOS 11.0)
   - Có thể break nhiều API đang dùng

7. **Thay đổi SDK path trong `build.sh`**
   - Đã fix SDK mismatch một lần, cẩn thận regress

8. **Sửa `build.sh` flags** (`-Osize`, `-wmo`, `-dead_strip`)
   - Ảnh hưởng đến binary size và performance

9. **Xóa hoặc thay đổi UserDefaults key names**
   - Ảnh hưởng settings của user đang dùng

---

### 🟡 Mức Thấp — Nhắc Nhở Trước Khi Làm

10. **Hành động tác động lên filesystem ngoài project folder**
    - Ví dụ: ghi vào `~/Library/`, `/Applications/`, `/tmp/`

11. **Chạy `install.sh` hoặc `uninstall.sh`**
    - Tác động lên `/Applications/` và system LaunchAgents

---

## Template Hỏi User

```
⚠️ CRITICAL CHANGE DETECTED

Tôi cần thực hiện: [mô tả hành động]
File/location: [path]
Lý do cần: [giải thích ngắn]
Rủi ro nếu sai: [mô tả rủi ro]

Bạn có muốn tiếp tục không?
```
