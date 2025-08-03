// ABOUTME: SpinBox provides a numeric input field with increment/decrement buttons
// ABOUTME: This wraps Qt's QSpinBox for use in Swift applications

import Foundation
import QtBridge

/// A spin box widget for integer value input.
///
/// SpinBox provides a convenient way for users to input integer values,
/// with increment and decrement buttons, keyboard input, and value validation.
///
/// ## Example Usage
///
/// ```swift
/// let spinBox = SpinBox()
/// spinBox.minimum = 0
/// spinBox.maximum = 100
/// spinBox.value = 50
/// spinBox.singleStep = 5
/// spinBox.onValueChanged { value in
///     print("Value changed to: \(value)")
/// }
/// ```
@MainActor
public class SpinBox: SafeEventWidget, QtWidget {
    /// Button symbol styles
    public enum ButtonSymbols: Int {
        case upDown = 0      // Traditional up/down arrows
        case plusMinus = 1   // Plus/minus symbols
        case noButtons = 2   // No buttons (keyboard input only)
    }
    
    /// The underlying Qt spin box stored as a pointer
    nonisolated(unsafe) internal var qtSpinBox: UnsafeMutablePointer<SwiftQSpinBox>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQSpinBox* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtSpinBox).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current value
    public var value: Int {
        get {
            return Int(qtSpinBox.pointee.value())
        }
        set {
            qtSpinBox.pointee.setValue(Int32(newValue))
        }
    }
    
    /// The minimum allowed value
    public var minimum: Int {
        get {
            return Int(qtSpinBox.pointee.minimum())
        }
        set {
            qtSpinBox.pointee.setMinimum(Int32(newValue))
        }
    }
    
    /// The maximum allowed value
    public var maximum: Int {
        get {
            return Int(qtSpinBox.pointee.maximum())
        }
        set {
            qtSpinBox.pointee.setMaximum(Int32(newValue))
        }
    }
    
    /// The step value for increment/decrement
    public var singleStep: Int {
        get {
            return Int(qtSpinBox.pointee.singleStep())
        }
        set {
            qtSpinBox.pointee.setSingleStep(Int32(newValue))
        }
    }
    
    /// Text displayed before the value
    public var prefix: String {
        get {
            return String(qtSpinBox.pointee.prefix())
        }
        set {
            qtSpinBox.pointee.setPrefix(std.string(newValue))
        }
    }
    
    /// Text displayed after the value
    public var suffix: String {
        get {
            return String(qtSpinBox.pointee.suffix())
        }
        set {
            qtSpinBox.pointee.setSuffix(std.string(newValue))
        }
    }
    
    /// Special text displayed when value equals minimum
    public var specialValueText: String {
        get {
            return String(qtSpinBox.pointee.specialValueText())
        }
        set {
            qtSpinBox.pointee.setSpecialValueText(std.string(newValue))
        }
    }
    
    /// Whether values wrap around at min/max boundaries
    public var wrapping: Bool {
        get {
            return qtSpinBox.pointee.wrapping()
        }
        set {
            qtSpinBox.pointee.setWrapping(newValue)
        }
    }
    
    /// The style of increment/decrement buttons
    public var buttonSymbols: ButtonSymbols {
        get {
            return ButtonSymbols(rawValue: Int(qtSpinBox.pointee.buttonSymbols())) ?? .upDown
        }
        set {
            qtSpinBox.pointee.setButtonSymbols(Int32(newValue.rawValue))
        }
    }
    
    /// Text alignment within the spin box
    public var alignment: Qt.Alignment {
        get {
            return Qt.Alignment(rawValue: Int32(qtSpinBox.pointee.alignment())) ?? .left
        }
        set {
            qtSpinBox.pointee.setAlignment(Int32(newValue.rawValue))
        }
    }
    
    /// Whether the spin box is read-only
    public var isReadOnly: Bool {
        get {
            return qtSpinBox.pointee.isReadOnly()
        }
        set {
            qtSpinBox.pointee.setReadOnly(newValue)
        }
    }
    
    /// Creates a new spin box
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level spin box.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtSpinBox = UnsafeMutablePointer<SwiftQSpinBox>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtSpinBox.initialize(to: SwiftQSpinBox(parent.getBridgeWidget()))
        } else {
            qtSpinBox.initialize(to: SwiftQSpinBox())
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtSpinBox
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the value range
    ///
    /// - Parameters:
    ///   - min: The minimum value
    ///   - max: The maximum value
    public func setRange(min: Int, max: Int) {
        qtSpinBox.pointee.setRange(Int32(min), Int32(max))
    }
    
    /// Sets a handler for value change events
    /// - Parameter handler: Closure called when the value changes
    public func onValueChanged(_ handler: @escaping (Int) -> Void) {
        // TODO: Connect to valueChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtSpinBox.pointee.show()
    }
    
    public func hide() {
        qtSpinBox.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtSpinBox.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtSpinBox.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtSpinBox.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtSpinBox.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtSpinBox.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtSpinBox.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtSpinBox.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtSpinBox.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtSpinBox.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtSpinBox.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtSpinBox.pointee.setParent(nil)
        }
    }
}