import AppKit

public class BaseStatsView: NSView {
    public var onClick: (() -> Void)?
    public var onRightClick: (() -> Void)?

    override public func mouseDown(with event: NSEvent) {
        onClick?()
    }

    override public func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }
}

// MARK: - Color Utilities
private enum AlertLevel: Int {
    case normal = 0
    case warning = 1
    case high = 2
    case critical = 3
}

private func discreteColor(level: AlertLevel, isDark: Bool) -> NSColor {
    switch level {
    case .normal: // Green
        return isDark ? NSColor(calibratedHue: 130.0/360.0, saturation: 0.40, brightness: 0.92, alpha: 1.0)
                      : NSColor(calibratedHue: 130.0/360.0, saturation: 0.85, brightness: 0.32, alpha: 1.0)
    case .warning: // Yellow
        return isDark ? NSColor(calibratedHue: 48.0/360.0, saturation: 0.45, brightness: 0.95, alpha: 1.0)
                      : NSColor(calibratedHue: 48.0/360.0, saturation: 0.85, brightness: 0.38, alpha: 1.0)
    case .high: // Orange
        return isDark ? NSColor(calibratedHue: 28.0/360.0, saturation: 0.50, brightness: 0.95, alpha: 1.0)
                      : NSColor(calibratedHue: 28.0/360.0, saturation: 0.85, brightness: 0.40, alpha: 1.0)
    case .critical: // Red
        return isDark ? NSColor(calibratedHue: 0.0/360.0, saturation: 0.50, brightness: 0.95, alpha: 1.0)
                      : NSColor(calibratedHue: 0.0/360.0, saturation: 0.85, brightness: 0.42, alpha: 1.0)
    }
}

private func levelForValue(_ value: Double, warn: Double, high: Double, crit: Double) -> AlertLevel {
    if value >= crit { return .critical }
    if value >= high { return .high }
    if value >= warn { return .warning }
    return .normal
}

private func colorForUsage(_ percent: Double, isDark: Bool, metricPrefix: String) -> NSColor {
    let warn = UserDefaults.standard.object(forKey: "\(metricPrefix)WarnThreshold") as? Double ?? 60.0
    let high = UserDefaults.standard.object(forKey: "\(metricPrefix)HighThreshold") as? Double ?? 75.0
    let crit = UserDefaults.standard.object(forKey: "\(metricPrefix)CriticalThreshold") as? Double ?? 90.0
    let level = levelForValue(percent, warn: warn, high: high, crit: crit)
    return discreteColor(level: level, isDark: isDark)
}

private func colorForTemperature(_ temp: Double, isDark: Bool) -> NSColor {
    let warn = UserDefaults.standard.object(forKey: "tempWarnThreshold") as? Double ?? 55.0
    let high = UserDefaults.standard.object(forKey: "tempHighThreshold") as? Double ?? 70.0
    let crit = UserDefaults.standard.object(forKey: "tempCriticalThreshold") as? Double ?? 85.0
    let level = levelForValue(temp, warn: warn, high: high, crit: crit)
    return discreteColor(level: level, isDark: isDark)
}

private func colorForNetworkSpeed(_ bytesPerSec: Double, isDark: Bool, defaultColor: NSColor) -> NSColor {
    guard bytesPerSec >= 1024.0 else { return defaultColor }
    let logKb = log10(bytesPerSec / 1024.0)
    let normalized = min(max(logKb / 4.5, 0.0), 1.0)
    // Map normalized speed [0, 1] to threshold levels roughly mapping to 40%, 60%, 80% full scale
    let level = levelForValue(normalized * 100.0, warn: 40.0, high: 60.0, crit: 80.0)
    return discreteColor(level: level, isDark: isDark)
}


// MARK: - Static constants (allocated once for app lifetime)
private let rightAlignStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .right
    return style
}()

private let font = NSFont.monospacedDigitSystemFont(ofSize: 9.0, weight: .bold)
private let unitFont = NSFont.monospacedSystemFont(ofSize: 9.0, weight: .bold)
private let cpuMemUnitFont = NSFont.systemFont(ofSize: 9.0, weight: .bold)
private let tempValFont = NSFont.monospacedDigitSystemFont(ofSize: 10.0, weight: .bold)

private let networkSectionWidth: CGFloat = 30.0
private let cpuMemWidthWithNetwork: CGFloat = 40.0
private let cpuMemWidthWithoutNetwork: CGFloat = 38.0
private let temperatureSectionWidth: CGFloat = 21.0

private let speedTiers: [(threshold: Double, divisor: Double, unit: String)] = [
    (1000.0,             1.0,              "B"),
    (1000.0 * 1024.0,    1024.0,           "K"),
    (1000.0 * 1048576.0, 1048576.0,        "M"),
    (Double.infinity,    1073741824.0,      "G"),
]

// MARK: - Unified Status Bar View with Cached Rendering
public class UnifiedStatsView: BaseStatsView {
    // Raw input values
    private var _cpuPercent: Double = -1
    private var _cpuTemperature: Double = -1
    private var _tempUnit: String = "C"
    private var _memGB: Double = -1
    private var _memPercent: Double = -1
    private var _uploadBPS: Double = -1
    private var _downloadBPS: Double = -1

    public var showNetwork: Bool = true
    public var showTemperature: Bool = true

    public static func calculateWidth(showNetwork: Bool, showTemperature: Bool) -> CGFloat {
        let netW: CGFloat = showNetwork ? networkSectionWidth : 0.0
        let cpuMemW: CGFloat = showNetwork ? cpuMemWidthWithNetwork : cpuMemWidthWithoutNetwork
        let tempW: CGFloat = showTemperature ? temperatureSectionWidth : 0.0
        return netW + cpuMemW + tempW
    }

    // Cached rendered attributed strings (survive across frames)
    private var cachedUpLine: NSAttributedString?
    private var cachedDownLine: NSAttributedString?
    private var cachedCpuLine: NSAttributedString?
    private var cachedMemLine: NSAttributedString?
    private var cachedTempLine: NSAttributedString?
    private var cachedTempUnitLine: NSAttributedString?

    // Cached raw values used as cache invalidation keys (avoid String allocation)
    private var lastUpBPS: Double = -1
    private var lastDownBPS: Double = -1
    private var lastCpuPct: Double = -1
    private var lastMemGB: Double = -1
    private var lastTempC: Double = -1
    private var lastTempUnit: String = ""

    // Cached appearance state
    private var cachedIsDark: Bool? = nil

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }

    public func updateValues(cpuPercent: Double, cpuTemperature: Double, tempUnit: String, memGB: Double, memPercent: Double,
                             uploadBytesPerSec: Double, downloadBytesPerSec: Double) {
        var changed = false
        if _cpuPercent != cpuPercent { _cpuPercent = cpuPercent; changed = true }
        if _cpuTemperature != cpuTemperature { _cpuTemperature = cpuTemperature; changed = true }
        if _tempUnit != tempUnit { _tempUnit = tempUnit; changed = true }
        if _memGB != memGB { _memGB = memGB; changed = true }
        if _memPercent != memPercent { _memPercent = memPercent; changed = true }
        if _uploadBPS != uploadBytesPerSec { _uploadBPS = uploadBytesPerSec; changed = true }
        if _downloadBPS != downloadBytesPerSec { _downloadBPS = downloadBytesPerSec; changed = true }
        if changed { needsDisplay = true }
    }

    private func formatSpeed(_ bytesPerSec: Double) -> (val: String, unit: String) {
        for tier in speedTiers {
            if bytesPerSec < tier.threshold {
                let scaled = bytesPerSec / tier.divisor
                if scaled < 10.0 && tier.divisor > 1.0 {
                    return (String(format: "%.1f", scaled), tier.unit)
                } else {
                    return (String(format: "%.0f", scaled), tier.unit)
                }
            }
        }
        return (String(format: "%.0f", bytesPerSec), "B")
    }

    private func buildLine(val: String, unit: String, color: NSColor, dimAlpha: CGFloat,
                           valFont: NSFont, uFont: NSFont) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(NSAttributedString(string: val, attributes: [
            .font: valFont, .foregroundColor: color, .paragraphStyle: rightAlignStyle
        ]))
        s.append(NSAttributedString(string: " " + unit, attributes: [
            .font: uFont, .foregroundColor: color.withAlphaComponent(dimAlpha), .paragraphStyle: rightAlignStyle
        ]))
        return s
    }

    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let appearanceChanged = (isDark != cachedIsDark)
        if appearanceChanged {
            cachedIsDark = isDark
            cachedUpLine = nil; cachedDownLine = nil; cachedCpuLine = nil; cachedMemLine = nil; cachedTempLine = nil; cachedTempUnitLine = nil
            lastUpBPS = -1; lastDownBPS = -1; lastCpuPct = -1; lastMemGB = -1; lastTempC = -1; lastTempUnit = ""
        }

        let textColor = isDark ? NSColor.white : NSColor.black
        let dimAlpha: CGFloat = isDark ? 0.75 : 0.65

        let line1Y: CGFloat = 11.0
        let line2Y: CGFloat = 1.0
        let lineH: CGFloat = 11.0
        
        let netW: CGFloat = showNetwork ? networkSectionWidth : 0.0
        let cpuMemW: CGFloat = showNetwork ? cpuMemWidthWithNetwork : cpuMemWidthWithoutNetwork
        let tempW: CGFloat = showTemperature ? temperatureSectionWidth : 0.0

        var currentX: CGFloat = 0.0

        if showNetwork {
            // Upload — only rebuild attributed string if raw value changed
            if cachedUpLine == nil || _uploadBPS != lastUpBPS {
                lastUpBPS = _uploadBPS
                let (upVal, upUnit) = formatSpeed(_uploadBPS)
                let upColor = colorForNetworkSpeed(_uploadBPS, isDark: isDark, defaultColor: textColor)
                cachedUpLine = buildLine(val: upVal, unit: upUnit, color: upColor, dimAlpha: dimAlpha,
                                         valFont: font, uFont: unitFont)
            }
            cachedUpLine!.draw(in: CGRect(x: currentX, y: line1Y, width: netW, height: lineH))

            // Download
            if cachedDownLine == nil || _downloadBPS != lastDownBPS {
                lastDownBPS = _downloadBPS
                let (downVal, downUnit) = formatSpeed(_downloadBPS)
                let downColor = colorForNetworkSpeed(_downloadBPS, isDark: isDark, defaultColor: textColor)
                cachedDownLine = buildLine(val: downVal, unit: downUnit, color: downColor, dimAlpha: dimAlpha,
                                           valFont: font, uFont: unitFont)
            }
            cachedDownLine!.draw(in: CGRect(x: currentX, y: line2Y, width: netW, height: lineH))
            
            currentX += netW
        }

        // CPU
        if cachedCpuLine == nil || _cpuPercent != lastCpuPct {
            lastCpuPct = _cpuPercent
            let cpuVal = String(format: "%.0f", _cpuPercent)
            let cpuColor = colorForUsage(_cpuPercent, isDark: isDark, metricPrefix: "cpu")
            cachedCpuLine = buildLine(val: cpuVal, unit: "%", color: cpuColor, dimAlpha: dimAlpha,
                                       valFont: font, uFont: cpuMemUnitFont)
        }
        cachedCpuLine!.draw(in: CGRect(x: currentX, y: line1Y, width: cpuMemW, height: lineH))

        // RAM
        if cachedMemLine == nil || _memGB != lastMemGB {
            lastMemGB = _memGB
            let memKey = String(format: "%.1f", _memGB)
            let memColor = colorForUsage(_memPercent, isDark: isDark, metricPrefix: "mem")
            cachedMemLine = buildLine(val: memKey, unit: "G", color: memColor, dimAlpha: dimAlpha,
                                       valFont: font, uFont: cpuMemUnitFont)
        }
        cachedMemLine!.draw(in: CGRect(x: currentX, y: line2Y, width: cpuMemW, height: lineH))
        
        currentX += cpuMemW

        if showTemperature {
            // Temperature
            let tempVal: String
            if _cpuTemperature > 0 {
                if _tempUnit == "F" {
                    tempVal = String(format: "%.0f", _cpuTemperature * 1.8 + 32.0)
                } else {
                    tempVal = String(format: "%.0f", _cpuTemperature)
                }
            } else {
                tempVal = "--"
            }
            
            if cachedTempLine == nil || _cpuTemperature != lastTempC || _tempUnit != lastTempUnit {
                lastTempC = _cpuTemperature
                lastTempUnit = _tempUnit
                let tempColor = _cpuTemperature > 0 ? colorForTemperature(_cpuTemperature, isDark: isDark) : textColor
                
                // Value line (Top, bigger font)
                let s1 = NSMutableAttributedString()
                s1.append(NSAttributedString(string: tempVal, attributes: [
                    .font: tempValFont, .foregroundColor: tempColor, .paragraphStyle: rightAlignStyle
                ]))
                cachedTempLine = s1
                
                // Unit line (Bottom, standard font, dimmed)
                let s2 = NSMutableAttributedString()
                s2.append(NSAttributedString(string: _cpuTemperature > 0 ? "°" + _tempUnit : "", attributes: [
                    .font: cpuMemUnitFont, .foregroundColor: tempColor.withAlphaComponent(dimAlpha), .paragraphStyle: rightAlignStyle
                ]))
                cachedTempUnitLine = s2
            }
            cachedTempLine!.draw(in: CGRect(x: currentX, y: line1Y, width: tempW, height: lineH))
            cachedTempUnitLine!.draw(in: CGRect(x: currentX, y: line2Y, width: tempW, height: lineH))
        }
    }
}
