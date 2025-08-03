// ABOUTME: LCDNumber provides a LCD-style number display widget
// ABOUTME: This wraps Qt's QLCDNumber for use in Swift applications

import Foundation
import QtBridge

/// A widget that displays numbers in LCD-like digits.
///
/// LCDNumber provides a retro-style seven-segment display for showing numeric values,
/// perfect for counters, timers, or any numeric display with a classic look.
///
/// ## Example Usage
///
/// ```swift
/// let lcd = LCDNumber()
/// lcd.digitCount = 5
/// lcd.mode = .decimal
/// lcd.segmentStyle = .filled
/// lcd.display(value: 42.5)
/// ```
@MainActor
public class LCDNumber: SafeEventWidget, QtWidget {
    /// Display modes for the LCD number
    public enum Mode: Int {
        case hexadecimal = 0  // Hexadecimal display
        case decimal = 1      // Decimal display (default)
        case octal = 2        // Octal display
        case binary = 3       // Binary display
    }
    
    /// Segment styles for the LCD display
    public enum SegmentStyle: Int {
        case outline = 0      // Outline segments
        case filled = 1       // Filled segments (default)
        case flat = 2         // Flat segments
    }
    
    /// The underlying Qt LCD number stored as a pointer
    nonisolated(unsafe) internal var qtLCDNumber: UnsafeMutablePointer<SwiftQLCDNumber>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQLCDNumber* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtLCDNumber).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current integer value displayed
    public var intValue: Int {
        get {
            return Int(qtLCDNumber.pointee.intValue())
        }
    }
    
    /// The current double value displayed
    public var value: Double {
        get {
            return qtLCDNumber.pointee.value()
        }
    }
    
    /// The number of digits displayed
    public var digitCount: Int {
        get {
            return Int(qtLCDNumber.pointee.digitCount())
        }
        set {
            qtLCDNumber.pointee.setDigitCount(Int32(newValue))
        }
    }
    
    /// The display mode (hex, decimal, octal, binary)
    public var mode: Mode {
        get {
            return Mode(rawValue: Int(qtLCDNumber.pointee.mode())) ?? .decimal
        }
        set {
            qtLCDNumber.pointee.setMode(Int32(newValue.rawValue))
        }
    }
    
    /// The segment style
    public var segmentStyle: SegmentStyle {
        get {
            return SegmentStyle(rawValue: Int(qtLCDNumber.pointee.segmentStyle())) ?? .filled
        }
        set {
            qtLCDNumber.pointee.setSegmentStyle(Int32(newValue.rawValue))
        }
    }
    
    /// Whether to show a small decimal point
    public var smallDecimalPoint: Bool {
        get {
            return qtLCDNumber.pointee.smallDecimalPoint()
        }
        set {
            qtLCDNumber.pointee.setSmallDecimalPoint(newValue)
        }
    }
    
    /// Creates a new LCD number widget
    ///
    /// - Parameters:
    ///   - digitCount: The number of digits to display (default is 5)
    ///   - parent: The parent widget. If nil, creates a top-level LCD number.
    public init(digitCount: Int = 5, parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtLCDNumber = UnsafeMutablePointer<SwiftQLCDNumber>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtLCDNumber.initialize(to: SwiftQLCDNumber(Int32(digitCount), parent.getBridgeWidget()))
        } else {
            qtLCDNumber.initialize(to: SwiftQLCDNumber())
            qtLCDNumber.pointee.setDigitCount(Int32(digitCount))
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtLCDNumber
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Displays an integer value
    ///
    /// - Parameter value: The integer value to display
    public func display(value: Int) {
        qtLCDNumber.pointee.display(Int32(value))
    }
    
    /// Displays a double value
    ///
    /// - Parameter value: The double value to display
    public func display(value: Double) {
        qtLCDNumber.pointee.display(value)
    }
    
    /// Displays a string value
    ///
    /// - Parameter text: The text to display (should contain only valid digits for the current mode)
    public func display(text: String) {
        qtLCDNumber.pointee.display(std.string(text))
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtLCDNumber.pointee.show()
    }
    
    public func hide() {
        qtLCDNumber.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtLCDNumber.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtLCDNumber.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtLCDNumber.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtLCDNumber.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtLCDNumber.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtLCDNumber.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtLCDNumber.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtLCDNumber.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtLCDNumber.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtLCDNumber.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtLCDNumber.pointee.setParent(nil)
        }
    }
}