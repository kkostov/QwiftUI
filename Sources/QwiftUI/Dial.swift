// ABOUTME: Dial provides a circular slider widget for value input
// ABOUTME: This wraps Qt's QDial for use in Swift applications

import Foundation
import QtBridge

/// A circular dial widget for selecting values.
///
/// Dial provides a rotary control for selecting values within a range,
/// useful for settings that benefit from a circular metaphor like volume or angle.
///
/// ## Example Usage
///
/// ```swift
/// let dial = Dial()
/// dial.minimum = 0
/// dial.maximum = 100
/// dial.value = 50
/// dial.notchesVisible = true
/// dial.wrapping = false
/// dial.onValueChanged { value in
///     print("Dial value: \(value)")
/// }
/// ```
@MainActor
public class Dial: SafeEventWidget, QtWidget {
    /// The underlying Qt dial stored as a pointer
    nonisolated(unsafe) internal var qtDial: UnsafeMutablePointer<SwiftQDial>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQDial* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtDial).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current value
    public var value: Int {
        get {
            return Int(qtDial.pointee.value())
        }
        set {
            qtDial.pointee.setValue(Int32(newValue))
        }
    }
    
    /// The minimum value
    public var minimum: Int {
        get {
            return Int(qtDial.pointee.minimum())
        }
        set {
            qtDial.pointee.setMinimum(Int32(newValue))
        }
    }
    
    /// The maximum value
    public var maximum: Int {
        get {
            return Int(qtDial.pointee.maximum())
        }
        set {
            qtDial.pointee.setMaximum(Int32(newValue))
        }
    }
    
    /// The single step value (for keyboard navigation)
    public var singleStep: Int {
        get {
            return Int(qtDial.pointee.singleStep())
        }
        set {
            qtDial.pointee.setSingleStep(Int32(newValue))
        }
    }
    
    /// The page step value (for page up/down keys)
    public var pageStep: Int {
        get {
            return Int(qtDial.pointee.pageStep())
        }
        set {
            qtDial.pointee.setPageStep(Int32(newValue))
        }
    }
    
    /// Whether notches are visible around the dial
    public var notchesVisible: Bool {
        get {
            return qtDial.pointee.notchesVisible()
        }
        set {
            qtDial.pointee.setNotchesVisible(newValue)
        }
    }
    
    /// The target number of pixels between notches
    public var notchTarget: Double {
        get {
            return qtDial.pointee.notchTarget()
        }
        set {
            qtDial.pointee.setNotchTarget(newValue)
        }
    }
    
    /// The size of notches
    public var notchSize: Int {
        get {
            return Int(qtDial.pointee.notchSize())
        }
    }
    
    /// Whether the dial wraps around when reaching min/max
    public var wrapping: Bool {
        get {
            return qtDial.pointee.wrapping()
        }
        set {
            qtDial.pointee.setWrapping(newValue)
        }
    }
    
    /// Creates a new dial widget
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level dial.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtDial = UnsafeMutablePointer<SwiftQDial>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtDial.initialize(to: SwiftQDial(parent.getBridgeWidget()))
        } else {
            qtDial.initialize(to: SwiftQDial())
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtDial
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the value range
    ///
    /// - Parameters:
    ///   - min: The minimum value
    ///   - max: The maximum value
    public func setRange(min: Int, max: Int) {
        qtDial.pointee.setRange(Int32(min), Int32(max))
    }
    
    /// Sets a handler for value change events
    /// - Parameter handler: Closure called when the value changes
    public func onValueChanged(_ handler: @escaping (Int) -> Void) {
        // TODO: Connect to valueChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtDial.pointee.show()
    }
    
    public func hide() {
        qtDial.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtDial.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtDial.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtDial.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtDial.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtDial.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtDial.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtDial.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtDial.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtDial.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtDial.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtDial.pointee.setParent(nil)
        }
    }
}