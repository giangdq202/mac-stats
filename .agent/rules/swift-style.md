# Rules: Swift Coding Style

## Nguyên Tắc Cốt Lõi

Đây là project **learn-by-doing** cho người mới Swift.
Agent phải giải thích code, không chỉ viết code.

---

## 1. Code Readability First

```swift
// ✅ TỐT: Rõ ràng, dễ đọc
if cpuPercent > criticalThreshold {
    return .red
} else if cpuPercent > warnThreshold {
    return .yellow
} else {
    return .green
}

// ❌ TRÁNH: Ternary lồng nhau, khó đọc cho người mới
return cpuPercent > critical ? .red : cpuPercent > warn ? .yellow : .green
```

---

## 2. Comment Là Bắt Buộc Với Code Mới

Mọi function mới phải có comment giải thích:
```swift
/// Trả về màu phù hợp dựa trên % sử dụng và threshold tùy chỉnh.
/// - Parameters:
///   - percent: Phần trăm sử dụng (0–100)
///   - isDark: True nếu đang dùng Dark Mode
/// - Returns: NSColor tương ứng (xanh/vàng/đỏ)
private func colorForUsageWithThreshold(_ percent: Double, isDark: Bool) -> NSColor {
    ...
}
```

---

## 3. UserDefaults Pattern

Luôn dùng computed property pattern cho settings:
```swift
// ✅ Pattern chuẩn của project này
private var cpuWarnThreshold: Double {
    get { UserDefaults.standard.object(forKey: "cpuWarnThreshold") as? Double ?? 50.0 }
    set { UserDefaults.standard.set(newValue, forKey: "cpuWarnThreshold") }
}
```

---

## 4. Màu Sắc

Không dùng màu hardcode cho dark/light mode:
```swift
// ✅ Dùng system colors
NSColor.labelColor        // Tự điều chỉnh theo mode
NSColor.secondaryLabelColor

// ✅ Hoặc calibrated color với isDark check
NSColor(calibratedHue: hue, saturation: sat, brightness: bright, alpha: 1.0)

// ❌ TRÁNH
NSColor(red: 1, green: 0, blue: 0, alpha: 1)  // Không tự điều chỉnh
```

---

## 5. Không Dùng Force Unwrap Với User Input

```swift
// ✅ Safe
if let value = sender.representedObject as? Double {
    cpuWarnThreshold = value
}

// ❌ Unsafe
let value = sender.representedObject as! Double  // Crash nếu nil
```
