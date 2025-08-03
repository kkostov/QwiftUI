// ABOUTME: Button widget implementation conforming to QtClickable protocol
// ABOUTME: Provides a clickable button with text label and comprehensive event support

import Foundation
import QtBridge

/// A push button widget that users can click to trigger actions
@MainActor
public class Button: SafeEventWidget, QtWidget, QtClickable {
    /// The underlying Qt button stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtButton: UnsafeMutablePointer<SwiftQPushButton>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQPushButton* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtButton).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The text displayed on the button
    public var text: String {
        get { String(qtButton.pointee.text()) }
        set { qtButton.pointee.setText(std.string(newValue)) }
    }
    
    /// Whether this is the default button (responds to Enter key)
    public var isDefault: Bool = false {
        didSet { qtButton.pointee.setDefault(isDefault) }
    }
    
    /// Whether the button appears flat (no raised border)
    public var isFlat: Bool = false {
        didSet { qtButton.pointee.setFlat(isFlat) }
    }
    
    /// Whether the button can be toggled (checkable)
    public var isCheckable: Bool = false {
        didSet { qtButton.pointee.setCheckable(isCheckable) }
    }
    
    /// Whether the button is checked (for checkable buttons)
    public var isChecked: Bool {
        get { qtButton.pointee.isChecked() }
        set { qtButton.pointee.setChecked(newValue) }
    }
    
    /// Creates a button with the specified text
    public init(_ text: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtButton = UnsafeMutablePointer<SwiftQPushButton>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtButton.initialize(to: SwiftQPushButton(std.string(text), parent.getBridgeWidget()))
        } else {
            qtButton.initialize(to: SwiftQPushButton(std.string(text)))
        }
        
        // Call super.init() after all stored properties are initialized
        super.init()
    }
    
    deinit {
        // Since Button is MainActor-isolated, we can safely access qtButton
        // The pointer deallocation is safe from deinit
        let ptr = qtButton
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtButton.pointee.show()
    }
    
    public func hide() {
        qtButton.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtButton.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtButton.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtButton.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtButton.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtButton.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtButton.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtButton.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtButton.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtButton.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtButton.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtButton.pointee.setParent(nil)
        }
    }
    
    // MARK: - Event Handling
    
    /// Sets a closure to be called when the button is clicked
    /// - Parameter handler: The closure to execute on button click
    @discardableResult
    public func onClicked(_ handler: @escaping () -> Void) -> Self {
        // Create a heap-allocated callback (automatically managed)
        let callback = CallbackHelper.createCallback(context: self, handler: handler)
        
        // Pass the callback to C++
        qtButton.pointee.setClickHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when the button is pressed (mouse down)
    /// - Parameter handler: The closure to execute on button press
    @discardableResult
    public func onPressed(_ handler: @escaping () -> Void) -> Self {
        // Create a heap-allocated event callback (automatically managed)
        let callback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.Pressed {
                handler()
            }
        }
        
        // Pass the callback to C++
        qtButton.pointee.setPressedHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when the button is released (mouse up)
    /// - Parameter handler: The closure to execute on button release
    @discardableResult
    public func onReleased(_ handler: @escaping () -> Void) -> Self {
        // Create a heap-allocated event callback (automatically managed)
        let callback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.Released {
                handler()
            }
        }
        
        // Pass the callback to C++
        qtButton.pointee.setReleasedHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when the button toggle state changes (for checkable buttons)
    /// - Parameter handler: The closure to execute with the new checked state
    @discardableResult
    public func onToggled(_ handler: @escaping (Bool) -> Void) -> Self {
        // Create a heap-allocated event callback (automatically managed)
        let callback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.Toggled {
                handler(info.boolValue)
            }
        }
        
        // Pass the callback to C++
        qtButton.pointee.setToggledHandler(callback.pointee)
        
        return self
    }
}