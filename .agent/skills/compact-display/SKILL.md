---
name: compact-display
description: >
  Hướng dẫn implement Compact Display mode cho mac-stats: hiển thị tối thiểu
  trên menu bar, tốn ít pixel nhất có thể. Kích hoạt khi người dùng muốn:
  thu gọn hiển thị, ẩn bớt thông tin, tùy chỉnh layout menu bar,
  hoặc thêm "Compact Mode" toggle.
---

# Skill: Compact Display Mode

## Mục Tiêu
Thêm toggle "Compact Mode" ẩn labels đơn vị và giảm spacing,
chỉ giữ lại số quan trọng nhất.

## Concept: Width Modes

```
Normal Mode:  [15 ↑  3.2 K] [23 %  8.1 G] [52 °C]   → ~91px
Compact Mode: [15↑ 3K] [23% 8G] [52°]               → ~65px
Minimal Mode: [23%] [8G]                             → ~38px
```

## Bước 1: Thêm displayMode Property (AppDelegate.swift)

```swift
// Thêm enum ở đầu file hoặc trong class
enum DisplayMode: String {
    case normal   = "normal"
    case compact  = "compact"
    case minimal  = "minimal"
}

// Computed property
private var displayMode: DisplayMode {
    get {
        let raw = UserDefaults.standard.string(forKey: "displayMode") ?? "normal"
        return DisplayMode(rawValue: raw) ?? .normal
    }
    set {
        UserDefaults.standard.set(newValue.rawValue, forKey: "displayMode")
        updateUIForSettingsChange()
    }
}
```

## Bước 2: Thêm Mode vào StatusBarView.swift

```swift
public enum DisplayMode: String {
    case normal, compact, minimal
}

public var displayMode: DisplayMode = .normal {
    didSet { needsDisplay = true }
}

// Cập nhật calculateWidth để tính theo mode
public static func calculateWidth(showNetwork: Bool, showTemperature: Bool, mode: DisplayMode) -> CGFloat {
    switch mode {
    case .normal:
        // Width hiện tại
        let netW: CGFloat = showNetwork ? 30.0 : 0.0
        let cpuMemW: CGFloat = showNetwork ? 40.0 : 38.0
        let tempW: CGFloat = showTemperature ? 21.0 : 0.0
        return netW + cpuMemW + tempW
    case .compact:
        let netW: CGFloat = showNetwork ? 22.0 : 0.0
        let cpuMemW: CGFloat = 30.0
        let tempW: CGFloat = showTemperature ? 16.0 : 0.0
        return netW + cpuMemW + tempW
    case .minimal:
        return 38.0  // Chỉ CPU% và RAM GB
    }
}
```

## Bước 3: Sửa draw() trong StatusBarView.swift

```swift
// Trong draw(), kiểm tra mode trước khi format:
let upStr: String
let upUnitStr: String

switch displayMode {
case .normal:
    (upStr, upUnitStr) = formatSpeed(_uploadBPS)
    // Vẽ cả value và unit
case .compact:
    let (val, unit) = formatSpeed(_uploadBPS)
    upStr = val
    upUnitStr = String(unit.prefix(1))  // "K" thay vì "KB"
case .minimal:
    break  // Không vẽ network
}
```

## Bước 4: Thêm Menu Item

```swift
// Trong showMenu():
let displayModeSubmenu = NSMenu()
for (label, mode) in [("Normal", DisplayMode.normal),
                       ("Compact", DisplayMode.compact),
                       ("Minimal (CPU+RAM only)", DisplayMode.minimal)] {
    let item = NSMenuItem(title: label, action: #selector(changeDisplayMode(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = mode.rawValue
    item.state = (displayMode == mode) ? .on : .off
    displayModeSubmenu.addItem(item)
}

let displayItem = NSMenuItem(title: "Display Mode", action: nil, keyEquivalent: "")
displayItem.submenu = displayModeSubmenu
menu.addItem(displayItem)
```

## Bước 5: Handler

```swift
@objc private func changeDisplayMode(_ sender: NSMenuItem) {
    if let raw = sender.representedObject as? String,
       let mode = DisplayMode(rawValue: raw) {
        displayMode = mode
    }
}
```
