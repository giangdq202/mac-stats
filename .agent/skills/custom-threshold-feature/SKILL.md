---
name: custom-threshold-feature
description: >
  Hướng dẫn implement tính năng custom color thresholds cho mac-stats.
  Kích hoạt skill này khi người dùng muốn: thêm cảnh báo màu theo mức (%),
  thêm settings để tùy chỉnh ngưỡng CPU/RAM/Temperature, hoặc thay đổi
  hệ thống màu từ gradient sang discrete (xanh/vàng/đỏ).
---

# Skill: Custom Color Threshold Feature

## Mục Tiêu
Thay thế hệ thống màu gradient liên tục hiện tại bằng 3 màu rõ ràng
với ngưỡng do người dùng tự cấu hình.

## Kiến Trúc Thay Đổi

```
UserDefaults ←→ AppDelegate (settings) → StatusBarView (rendering)
                     ↑
              Menu Settings UI
```

## Bước 1: Thêm Threshold Properties vào AppDelegate.swift

Thêm sau `showCPUTemperature` property (~dòng 341):

```swift
// MARK: - Custom Thresholds

private var cpuWarnThreshold: Double {
    get { UserDefaults.standard.object(forKey: "cpuWarnThreshold") as? Double ?? 50.0 }
    set { UserDefaults.standard.set(newValue, forKey: "cpuWarnThreshold"); updateStats() }
}

private var cpuCriticalThreshold: Double {
    get { UserDefaults.standard.object(forKey: "cpuCriticalThreshold") as? Double ?? 80.0 }
    set { UserDefaults.standard.set(newValue, forKey: "cpuCriticalThreshold"); updateStats() }
}

private var memWarnThreshold: Double {
    get { UserDefaults.standard.object(forKey: "memWarnThreshold") as? Double ?? 70.0 }
    set { UserDefaults.standard.set(newValue, forKey: "memWarnThreshold"); updateStats() }
}

private var memCriticalThreshold: Double {
    get { UserDefaults.standard.object(forKey: "memCriticalThreshold") as? Double ?? 90.0 }
    set { UserDefaults.standard.set(newValue, forKey: "memCriticalThreshold"); updateStats() }
}
```

## Bước 2: Truyền Threshold Xuống StatusBarView

Sửa `updateStats()` trong AppDelegate để pass thresholds:
```swift
statsView.updateValues(
    cpuPercent: currentCpuStats.usagePercent,
    cpuWarn: cpuWarnThreshold,        // thêm
    cpuCritical: cpuCriticalThreshold, // thêm
    memPercent: currentMemStats.usedPercent,
    memWarn: memWarnThreshold,         // thêm
    memCritical: memCriticalThreshold, // thêm
    ...
)
```

## Bước 3: Sửa StatusBarView.swift

Thêm stored properties:
```swift
private var _cpuWarn: Double = 50.0
private var _cpuCritical: Double = 80.0
private var _memWarn: Double = 70.0
private var _memCritical: Double = 90.0
```

Thêm hàm màu mới (thay thế `colorForUsage`):
```swift
/// Trả về màu dựa trên threshold rõ ràng (không gradient).
/// Xanh = bình thường, Vàng = cảnh báo, Đỏ = nguy hiểm.
private func colorForThreshold(_ value: Double, warn: Double, critical: Double, isDark: Bool) -> NSColor {
    if value >= critical {
        return isDark ? NSColor(calibratedHue: 0.0, saturation: 0.7, brightness: 1.0, alpha: 1.0)
                      : NSColor(calibratedHue: 0.0, saturation: 0.9, brightness: 0.7, alpha: 1.0)
    } else if value >= warn {
        return isDark ? NSColor(calibratedHue: 0.13, saturation: 0.7, brightness: 1.0, alpha: 1.0)
                      : NSColor(calibratedHue: 0.13, saturation: 0.9, brightness: 0.6, alpha: 1.0)
    } else {
        return isDark ? NSColor(calibratedHue: 0.33, saturation: 0.5, brightness: 0.95, alpha: 1.0)
                      : NSColor(calibratedHue: 0.33, saturation: 0.8, brightness: 0.35, alpha: 1.0)
    }
}
```

## Bước 4: Thêm Settings Submenu vào AppDelegate.showMenu()

```swift
// Thêm sau tempUnitItem:
let thresholdSubmenu = NSMenu()

// CPU thresholds
for (label, warn, crit) in [("Conservative (50/80%)", 50.0, 80.0),
                              ("Balanced (60/85%)", 60.0, 85.0),
                              ("Aggressive (70/90%)", 70.0, 90.0)] {
    let item = NSMenuItem(title: label, action: #selector(changeCPUThreshold(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = [warn, crit]
    item.state = (cpuWarnThreshold == warn && cpuCriticalThreshold == crit) ? .on : .off
    thresholdSubmenu.addItem(item)
}

let thresholdItem = NSMenuItem(title: "CPU Alert Levels", action: nil, keyEquivalent: "")
thresholdItem.submenu = thresholdSubmenu
menu.addItem(thresholdItem)
```

## Kiểm Tra Sau Khi Implement
1. Build: `bash build.sh`
2. Mở menu bar → click icon
3. Thấy "CPU Alert Levels" submenu
4. Chọn preset → màu CPU thay đổi ngay
5. Quit và reopen → preset vẫn giữ nguyên
