# Rules: mac-stats Development

## 1. Code Safety Rules

### Swift Files
- Luôn giữ các comments và docstrings gốc, chỉ thêm không xóa
- Mỗi thay đổi phải backward-compatible với macOS 11.0+
- Không dùng `@available` guard để bypass — phải hỗ trợ fallback thực sự
- Sau khi sửa file Swift bất kỳ, PHẢI chạy `bash build.sh` để verify

### Memory Management
- Mỗi `UnsafeMutablePointer` allocation phải có tương ứng `vm_deallocate` hoặc `free`
- Không tạo strong reference cycles (dùng `[weak self]` trong closures)
- Không allocate trong hot path (hàm `draw()`, timer callback)

### Settings / UserDefaults
- Mọi key mới phải được document trong `AGENTS.md` bảng "Key Files Reference"
- Default values phải conservative (ví dụ: warn=50%, critical=80%)
- Xóa key cũ: dùng `UserDefaults.standard.removeObject(forKey:)`

---

## 2. Build Rules

- Không thay đổi deployment target dưới `11.0` trong `build.sh`
- Không bỏ flag `-Osize`, `-wmo`, `-dead_strip` — đây là tối ưu quan trọng
- SDK path phải giữ nguyên: `/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk`
- Universal binary (arm64 + x86_64) là bắt buộc, không build single-arch

---

## 3. UI / Display Rules

- Menu bar width phải luôn tính qua `UnifiedStatsView.calculateWidth()`
- Font phải là monospaced cho số (đã dùng `monospacedDigitSystemFont`)
- Màu phải support cả Dark và Light mode
- Không hardcode pixel values trong `draw()` — dùng constants đã định nghĩa

---

## 4. Git / Version Control Rules

- File trong `.gitignore` không được add force
- Build artifacts (`*.app`, `*_arm64`, `*_x86_64`, `*_bin`) không commit
- Mỗi feature nên là 1 commit riêng với message rõ ràng:
  ```
  feat: add custom CPU threshold settings
  fix: correct network bytes calculation on M4
  refactor: extract color logic to separate function
  ```

---

## 5. Testing Rules (Manual)

Sau mỗi thay đổi, kiểm tra:
- [ ] Build thành công không có warning mới
- [ ] App launch, icon xuất hiện trên menu bar
- [ ] Click menu bar → menu hiện đúng
- [ ] Settings được persist sau khi quit và reopen
- [ ] Dark mode và Light mode đều hiển thị đúng màu
