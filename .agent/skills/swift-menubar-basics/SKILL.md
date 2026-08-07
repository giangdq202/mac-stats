---
name: swift-menubar-basics
description: >
  Hướng dẫn các pattern Swift và AppKit cơ bản cho macOS Menu Bar app.
  Kích hoạt skill này khi người dùng hỏi về: NSColor, NSFont, NSMenuItem,
  UserDefaults, NSView drawing, AppKit layout, hoặc bất kỳ concept Swift cơ bản nào.
---

# Skill: Swift Menu Bar App Basics

## 1. Colors (NSColor)

```swift
// Màu theo system (tự điều chỉnh dark/light)
NSColor.labelColor           // Màu text chính
NSColor.secondaryLabelColor  // Màu text phụ (mờ hơn)
NSColor.systemRed            // Đỏ system
NSColor.systemYellow         // Vàng system
NSColor.systemGreen          // Xanh lá system

// Màu HSL tùy chỉnh (cách project này dùng)
NSColor(calibratedHue: 0.33,    // 0.0=đỏ, 0.33=xanh, 0.66=tím
        saturation: 0.8,         // 0.0=xám, 1.0=đậm
        brightness: 0.9,         // 0.0=đen, 1.0=sáng
        alpha: 1.0)

// Kiểm tra dark mode
let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
```

## 2. UserDefaults (Lưu Settings)

```swift
// Lưu giá trị
UserDefaults.standard.set(50.0, forKey: "cpuWarnThreshold")
UserDefaults.standard.set(true, forKey: "showNetworkSpeeds")

// Đọc giá trị (với default nếu chưa có)
let threshold = UserDefaults.standard.double(forKey: "cpuWarnThreshold")
// Nếu chưa set → trả về 0.0, không phải nil

// Pattern an toàn hơn cho object types
let show = UserDefaults.standard.object(forKey: "showNetworkSpeeds") as? Bool ?? true
//                                                                              ^^^^ default

// Xóa key
UserDefaults.standard.removeObject(forKey: "cpuWarnThreshold")
```

## 3. NSMenuItem (Menu Items)

```swift
// Item thường
let item = NSMenuItem(title: "My Option", action: #selector(myAction(_:)), keyEquivalent: "")
item.target = self
menu.addItem(item)

// Item có checkmark
item.state = isEnabled ? .on : .off

// Item với submenu
let submenu = NSMenu()
submenu.addItem(...)
let parentItem = NSMenuItem(title: "Submenu", action: nil, keyEquivalent: "")
parentItem.submenu = submenu
menu.addItem(parentItem)

// Separator
menu.addItem(NSMenuItem.separator())

// Section header (disabled, nhỏ hơn)
let header = NSMenuItem(title: "Section", action: nil, keyEquivalent: "")
header.isEnabled = false
menu.addItem(header)
```

## 4. NSView Drawing

```swift
override public func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Vẽ text
    let text = "Hello"
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 10),
        .foregroundColor: NSColor.labelColor
    ]
    text.draw(at: CGPoint(x: 5, y: 5), withAttributes: attrs)
    
    // Vẽ rectangle
    NSColor.systemBlue.setFill()
    NSRect(x: 0, y: 0, width: bounds.width, height: 2).fill()
}
```

## 5. if/guard Pattern

```swift
// if let — dùng khi cần cả hai nhánh
if let value = optionalValue {
    // dùng value
} else {
    // xử lý nil
}

// guard let — dùng khi nil là exit case (preferred trong functions)
guard let value = optionalValue else {
    return  // hoặc return default, hoặc throw error
}
// Tiếp tục dùng value ở đây
```

## 6. Closure và [weak self]

```swift
// Lý do dùng [weak self]: tránh memory leak (retain cycle)
Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
    // Nếu không có [weak self] → app giữ timer, timer giữ app → leak
    self?.updateStats()  // Dấu ? vì self có thể nil
}

// onClick closure trong project này
statsView.onClick = { [weak self] in
    self?.showMenu()
}
```
