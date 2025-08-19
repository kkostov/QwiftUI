// ABOUTME: DoubleSpinBox widget implementation for floating-point number input
// ABOUTME: Provides a spin box with up/down arrows for decimal value selection

import Foundation
import QtBridge

/// A spin box widget for entering and adjusting floating-point values
///
/// DoubleSpinBox provides a text field with up/down arrows for entering
/// and adjusting decimal numbers within a specified range.
///
/// Example:
/// ```swift
/// let spinBox = DoubleSpinBox()
/// spinBox.setRange(0.0, 100.0)
/// spinBox.setSingleStep(0.1)
/// spinBox.setDecimals(2)
/// spinBox.setValue(50.5)
/// spinBox.setSuffix(" %")
/// ```
@MainActor
public class DoubleSpinBox: SafeEventWidget, QtWidget {
    /// The underlying Qt double spin box stored as a pointer
    nonisolated(unsafe) internal var qtDoubleSpinBox: UnsafeMutablePointer<SwiftQDoubleSpinBox>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQDoubleSpinBox* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtDoubleSpinBox).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// Creates a double spin box with optional parent
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtDoubleSpinBox = UnsafeMutablePointer<SwiftQDoubleSpinBox>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtDoubleSpinBox.initialize(to: SwiftQDoubleSpinBox(parent.getBridgeWidget()))
        } else {
            qtDoubleSpinBox.initialize(to: SwiftQDoubleSpinBox())
        }
    }
    
    deinit {
        // The pointer deallocation is safe from deinit
        let ptr = qtDoubleSpinBox
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    // MARK: - Value Management
    
    /// The current value of the spin box
    public var value: Double {
        get { qtDoubleSpinBox.pointee.value() }
        set { qtDoubleSpinBox.pointee.setValue(newValue) }
    }
    
    /// Sets the current value
    @discardableResult
    public func setValue(_ value: Double) -> Self {
        qtDoubleSpinBox.pointee.setValue(value)
        return self
    }
    
    // MARK: - Range Configuration
    
    /// The minimum allowed value
    public var minimum: Double {
        get { qtDoubleSpinBox.pointee.minimum() }
        set { qtDoubleSpinBox.pointee.setMinimum(newValue) }
    }
    
    /// The maximum allowed value
    public var maximum: Double {
        get { qtDoubleSpinBox.pointee.maximum() }
        set { qtDoubleSpinBox.pointee.setMaximum(newValue) }
    }
    
    /// Sets the minimum value
    @discardableResult
    public func setMinimum(_ min: Double) -> Self {
        qtDoubleSpinBox.pointee.setMinimum(min)
        return self
    }
    
    /// Sets the maximum value
    @discardableResult
    public func setMaximum(_ max: Double) -> Self {
        qtDoubleSpinBox.pointee.setMaximum(max)
        return self
    }
    
    /// Sets both minimum and maximum values
    @discardableResult
    public func setRange(_ min: Double, _ max: Double) -> Self {
        qtDoubleSpinBox.pointee.setRange(min, max)
        return self
    }
    
    // MARK: - Step Configuration
    
    /// The step value for increment/decrement
    public var singleStep: Double {
        get { qtDoubleSpinBox.pointee.singleStep() }
        set { qtDoubleSpinBox.pointee.setSingleStep(newValue) }
    }
    
    /// Sets the step value
    @discardableResult
    public func setSingleStep(_ step: Double) -> Self {
        qtDoubleSpinBox.pointee.setSingleStep(step)
        return self
    }
    
    // MARK: - Decimal Precision
    
    /// The number of decimal places to display
    public var decimals: Int {
        get { Int(qtDoubleSpinBox.pointee.decimals()) }
        set { qtDoubleSpinBox.pointee.setDecimals(Int32(newValue)) }
    }
    
    /// Sets the number of decimal places
    @discardableResult
    public func setDecimals(_ decimals: Int) -> Self {
        qtDoubleSpinBox.pointee.setDecimals(Int32(decimals))
        return self
    }
    
    // MARK: - Prefix and Suffix
    
    /// The prefix text displayed before the value
    public var prefix: String {
        get { String(qtDoubleSpinBox.pointee.prefix()) }
        set { qtDoubleSpinBox.pointee.setPrefix(std.string(newValue)) }
    }
    
    /// The suffix text displayed after the value
    public var suffix: String {
        get { String(qtDoubleSpinBox.pointee.suffix()) }
        set { qtDoubleSpinBox.pointee.setSuffix(std.string(newValue)) }
    }
    
    /// Sets the prefix text
    @discardableResult
    public func setPrefix(_ prefix: String) -> Self {
        qtDoubleSpinBox.pointee.setPrefix(std.string(prefix))
        return self
    }
    
    /// Sets the suffix text
    @discardableResult
    public func setSuffix(_ suffix: String) -> Self {
        qtDoubleSpinBox.pointee.setSuffix(std.string(suffix))
        return self
    }
    
    // MARK: - Special Value
    
    /// Text to display when value equals minimum
    public var specialValueText: String {
        get { String(qtDoubleSpinBox.pointee.specialValueText()) }
        set { qtDoubleSpinBox.pointee.setSpecialValueText(std.string(newValue)) }
    }
    
    /// Sets the special value text
    @discardableResult
    public func setSpecialValueText(_ text: String) -> Self {
        qtDoubleSpinBox.pointee.setSpecialValueText(std.string(text))
        return self
    }
    
    // MARK: - Behavior Configuration
    
    /// Whether the value wraps from max to min or vice versa
    public var wrapping: Bool {
        get { qtDoubleSpinBox.pointee.wrapping() }
        set { qtDoubleSpinBox.pointee.setWrapping(newValue) }
    }
    
    /// Sets whether values wrap around
    @discardableResult
    public func setWrapping(_ wrap: Bool) -> Self {
        qtDoubleSpinBox.pointee.setWrapping(wrap)
        return self
    }
    
    /// Button symbol style for the spin box
    public enum ButtonSymbols: Int32 {
        case upDown = 0
        case plusMinus = 1
        case noButtons = 2
    }
    
    /// Sets the button symbols style
    @discardableResult
    public func setButtonSymbols(_ symbols: ButtonSymbols) -> Self {
        qtDoubleSpinBox.pointee.setButtonSymbols(symbols.rawValue)
        return self
    }
    
    /// Gets the current button symbols style
    public var buttonSymbols: ButtonSymbols {
        ButtonSymbols(rawValue: qtDoubleSpinBox.pointee.buttonSymbols()) ?? .upDown
    }
    
    // MARK: - Alignment
    
    /// Sets the text alignment
    @discardableResult
    public func setAlignment(_ alignment: Qt.Alignment) -> Self {
        qtDoubleSpinBox.pointee.setAlignment(Int32(alignment.rawValue))
        return self
    }
    
    /// Gets the current text alignment
    public var alignment: Qt.Alignment {
        Qt.Alignment(rawValue: qtDoubleSpinBox.pointee.alignment())
    }
    
    // MARK: - Read-Only State
    
    /// Whether the spin box is read-only
    public var isReadOnly: Bool {
        get { qtDoubleSpinBox.pointee.isReadOnly() }
        set { qtDoubleSpinBox.pointee.setReadOnly(newValue) }
    }
    
    /// Sets the read-only state
    @discardableResult
    public func setReadOnly(_ readOnly: Bool) -> Self {
        qtDoubleSpinBox.pointee.setReadOnly(readOnly)
        return self
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtDoubleSpinBox.pointee.show()
    }
    
    public func hide() {
        qtDoubleSpinBox.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtDoubleSpinBox.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtDoubleSpinBox.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtDoubleSpinBox.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtDoubleSpinBox.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtDoubleSpinBox.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtDoubleSpinBox.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtDoubleSpinBox.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtDoubleSpinBox.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtDoubleSpinBox.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtDoubleSpinBox.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtDoubleSpinBox.pointee.setParent(nil)
        }
    }
}